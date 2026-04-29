import { spawn } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import readline from "node:readline";
import { Type } from "typebox";

const REQUEST_TIMEOUT_MS = 60_000;
const STARTUP_SETTLE_MS = 750;
const MAX_TEXT_BYTES = 50 * 1024;
const MAX_TEXT_LINES = 2_000;
const MAX_RESULTS_LIMIT = 100;
const MAX_CONTEXT_LIMIT = 20;

function defaultFffMcpBin() {
  if (process.env.PI_FFF_MCP_BIN) {
    return process.env.PI_FFF_MCP_BIN;
  }

  const user = process.env.USER;
  if (user) {
    const profileBin = `/etc/profiles/per-user/${user}/bin/fff-mcp`;
    if (fs.existsSync(profileBin)) {
      return profileBin;
    }
  }

  return "fff-mcp";
}

function delay(ms, signal) {
  if (signal?.aborted) {
    return Promise.reject(new Error("Cancelled"));
  }

  return new Promise((resolve, reject) => {
    const cleanup = () => {
      clearTimeout(timeout);
      signal?.removeEventListener("abort", onAbort);
    };

    const timeout = setTimeout(() => {
      cleanup();
      resolve();
    }, ms);

    const onAbort = () => {
      cleanup();
      reject(new Error("Cancelled"));
    };

    signal?.addEventListener("abort", onAbort, { once: true });
  });
}

function findGitRoot(cwd) {
  let current = path.resolve(cwd);

  while (true) {
    if (fs.existsSync(path.join(current, ".git"))) {
      return current;
    }

    const parent = path.dirname(current);
    if (parent === current) {
      return path.resolve(cwd);
    }

    current = parent;
  }
}

function cleanArguments(args) {
  if (!args || typeof args !== "object" || Array.isArray(args)) {
    return {};
  }

  const cleaned = {};
  for (const [key, value] of Object.entries(args)) {
    if (value !== null && value !== undefined) {
      cleaned[key] = value;
    }
  }

  if (cleaned.max_results !== undefined && cleaned.maxResults === undefined) {
    cleaned.maxResults = cleaned.max_results;
    delete cleaned.max_results;
  }

  if (cleaned.outputMode !== undefined && cleaned.output_mode === undefined) {
    cleaned.output_mode = cleaned.outputMode;
    delete cleaned.outputMode;
  }

  if (typeof cleaned.maxResults === "number") {
    cleaned.maxResults = Math.max(1, Math.min(MAX_RESULTS_LIMIT, Math.floor(cleaned.maxResults)));
  }

  if (typeof cleaned.context === "number") {
    cleaned.context = Math.max(0, Math.min(MAX_CONTEXT_LIMIT, Math.floor(cleaned.context)));
  }

  if (typeof cleaned.patterns === "string") {
    cleaned.patterns = cleaned.patterns
      .split(/[\n,]/)
      .map((pattern) => pattern.trim())
      .filter(Boolean);
  }

  return cleaned;
}

function contentToText(content) {
  if (!Array.isArray(content)) {
    return "";
  }

  return content
    .map((item) => (item?.type === "text" && typeof item.text === "string" ? item.text : ""))
    .filter(Boolean)
    .join("\n");
}

function truncateText(text) {
  let output = text;
  let truncated = false;

  const lines = output.split(/\r?\n/);
  if (lines.length > MAX_TEXT_LINES) {
    output = lines.slice(0, MAX_TEXT_LINES).join("\n");
    truncated = true;
  }

  if (Buffer.byteLength(output, "utf8") > MAX_TEXT_BYTES) {
    output = Buffer.from(output, "utf8").subarray(0, MAX_TEXT_BYTES).toString("utf8");
    truncated = true;
  }

  if (truncated) {
    output += `\n\n[fff output truncated to ${MAX_TEXT_LINES} lines / ${MAX_TEXT_BYTES} bytes. Narrow the query or lower maxResults.]`;
  }

  return output;
}

function normalizeMcpContent(content) {
  if (!Array.isArray(content)) {
    return [{ type: "text", text: "No content returned by fff-mcp." }];
  }

  return content.map((item) => {
    if (item?.type === "text" && typeof item.text === "string") {
      return { type: "text", text: truncateText(item.text) };
    }

    return { type: "text", text: truncateText(JSON.stringify(item)) };
  });
}

function isIndexStillEmpty(result) {
  return /\b0 indexed\b/.test(contentToText(result?.content));
}

class FffMcpClient {
  constructor(cwd) {
    this.cwd = findGitRoot(cwd);
    this.command = defaultFffMcpBin();
    this.child = undefined;
    this.nextId = 1;
    this.pending = new Map();
    this.startPromise = undefined;
    this.lastStderr = "";
  }

  start(signal) {
    if (this.startPromise) {
      return this.startPromise;
    }

    this.child = spawn(this.command, [this.cwd, "--no-update-check"], {
      cwd: this.cwd,
      env: { ...process.env, NO_COLOR: "1" },
      stdio: ["pipe", "pipe", "pipe"],
    });

    readline.createInterface({ input: this.child.stdout, crlfDelay: Infinity }).on("line", (line) => {
      this.handleLine(line);
    });

    this.child.stderr.on("data", (chunk) => {
      this.lastStderr = `${this.lastStderr}${chunk.toString()}`.slice(-4_000);
    });

    this.child.on("error", (error) => {
      this.rejectAll(error);
    });

    this.child.on("exit", (code, childSignal) => {
      this.rejectAll(new Error(`fff-mcp exited (${code ?? childSignal ?? "unknown"})`));
      this.child = undefined;
      this.startPromise = undefined;
    });

    this.startPromise = (async () => {
      await this.request(
        "initialize",
        {
          protocolVersion: "2024-11-05",
          capabilities: {},
          clientInfo: { name: "pi-fff-mcp", version: "0.1.0" },
        },
        signal,
      );

      this.notify("notifications/initialized", {});
      await delay(STARTUP_SETTLE_MS, signal);
    })();

    return this.startPromise;
  }

  async callTool(name, args, signal) {
    await this.start(signal);

    let result;
    for (let attempt = 0; attempt < 6; attempt += 1) {
      result = await this.request("tools/call", { name, arguments: args }, signal);
      if (!isIndexStillEmpty(result)) {
        return result;
      }

      await delay(500 * (attempt + 1), signal);
    }

    return result;
  }

  request(method, params, signal) {
    if (!this.child?.stdin?.writable) {
      throw new Error(`fff-mcp is not running at ${this.command}`);
    }

    const id = this.nextId;
    this.nextId += 1;

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        cleanup();
        reject(new Error(`fff-mcp request timed out: ${method}`));
      }, REQUEST_TIMEOUT_MS);

      const onAbort = () => {
        cleanup();
        reject(new Error("Cancelled"));
      };

      const cleanup = () => {
        clearTimeout(timeout);
        this.pending.delete(id);
        signal?.removeEventListener("abort", onAbort);
      };

      this.pending.set(id, {
        resolve: (value) => {
          cleanup();
          resolve(value);
        },
        reject: (error) => {
          cleanup();
          reject(error);
        },
      });

      signal?.addEventListener("abort", onAbort, { once: true });

      try {
        this.child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
      } catch (error) {
        cleanup();
        reject(error);
      }
    });
  }

  notify(method, params) {
    if (!this.child?.stdin?.writable) {
      return;
    }

    this.child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`);
  }

  handleLine(line) {
    let message;
    try {
      message = JSON.parse(line);
    } catch {
      return;
    }

    if (message.id === undefined) {
      return;
    }

    const pending = this.pending.get(message.id);
    if (!pending) {
      return;
    }

    if (message.error) {
      pending.reject(new Error(message.error.message ?? JSON.stringify(message.error)));
      return;
    }

    pending.resolve(message.result);
  }

  rejectAll(error) {
    for (const pending of this.pending.values()) {
      pending.reject(error);
    }

    this.pending.clear();
  }

  stop() {
    this.rejectAll(new Error("fff-mcp stopped"));
    this.child?.kill();
    this.child = undefined;
    this.startPromise = undefined;
  }
}

const stringOptional = (description) => Type.Optional(Type.String({ description }));
const numberOptional = (description) => Type.Optional(Type.Number({ description }));

const findFilesParameters = Type.Object({
  query: Type.String({ description: "Fuzzy file name query. Keep it short: 1-2 terms." }),
  maxResults: numberOptional(`Maximum results. Default from fff-mcp, clamped to ${MAX_RESULTS_LIMIT}.`),
  cursor: stringOptional("Cursor from a previous fff_find_files result."),
});

const grepParameters = Type.Object({
  query: Type.String({ description: "Content search query with optional constraints, e.g. '*.nix piManagedSettings'. Prefer bare identifiers." }),
  maxResults: numberOptional(`Maximum matching lines. Default from fff-mcp, clamped to ${MAX_RESULTS_LIMIT}.`),
  cursor: stringOptional("Cursor from a previous fff_grep result."),
  output_mode: stringOptional("Output format. Usually omit this and use fff-mcp's default content mode."),
});

const multiGrepParameters = Type.Object({
  patterns: Type.Array(Type.String({ description: "Literal text pattern." }), {
    description: "Patterns to match with OR logic. Include naming variants together.",
  }),
  constraints: stringOptional("File constraints, e.g. '*.{ts,tsx} !test/'. Prefer broad constraints."),
  context: numberOptional(`Context lines before/after each match. Clamped to ${MAX_CONTEXT_LIMIT}.`),
  maxResults: numberOptional(`Maximum matching lines. Default from fff-mcp, clamped to ${MAX_RESULTS_LIMIT}.`),
  cursor: stringOptional("Cursor from a previous fff_multi_grep result."),
  output_mode: stringOptional("Output format. Usually omit this and use fff-mcp's default content mode."),
});

export default function fffMcpBridge(pi) {
  const clients = new Map();

  function getClient(cwd) {
    const root = findGitRoot(cwd);
    let client = clients.get(root);
    if (!client) {
      client = new FffMcpClient(root);
      clients.set(root, client);
    }

    return client;
  }

  async function executeMcpTool(mcpToolName, params, signal, ctx) {
    const args = cleanArguments(params);
    const client = getClient(ctx.cwd);
    const result = await client.callTool(mcpToolName, args, signal);

    if (result?.isError) {
      throw new Error(contentToText(result.content) || `fff-mcp ${mcpToolName} failed`);
    }

    return {
      content: normalizeMcpContent(result?.content),
      details: {
        mcpToolName,
        basePath: client.cwd,
      },
    };
  }

  pi.registerTool({
    name: "fff_find_files",
    label: "FFF Find Files",
    description: "FFF MCP fuzzy file-name search. Use to find files/modules by name; not for searching file contents.",
    promptSnippet: "Search file names quickly with fff-mcp frecency ranking.",
    promptGuidelines: [
      "Use fff_find_files when looking for a file or module by name in the current git repo; keep queries short.",
    ],
    parameters: findFilesParameters,
    prepareArguments: cleanArguments,
    execute: (_toolCallId, params, signal, _onUpdate, ctx) => executeMcpTool("find_files", params, signal, ctx),
  });

  pi.registerTool({
    name: "fff_grep",
    label: "FFF Grep",
    description: "FFF MCP content search. Default search tool for identifiers, definitions, usages, TODOs, and code patterns. Supports inline constraints like '*.nix query', 'src/ query', '!test/ query'.",
    promptSnippet: "Search file contents with fff-mcp; prefer bare identifiers and broad constraints.",
    promptGuidelines: [
      "Use fff_grep before built-in grep/find or shell rg when searching file contents in a git-indexed repo.",
      "Use fff_grep with one bare identifier or simple literal pattern; after two grep calls, read a top result instead of searching more.",
    ],
    parameters: grepParameters,
    prepareArguments: cleanArguments,
    execute: (_toolCallId, params, signal, _onUpdate, ctx) => executeMcpTool("grep", params, signal, ctx),
  });

  pi.registerTool({
    name: "fff_multi_grep",
    label: "FFF Multi Grep",
    description: "FFF MCP content search for OR logic across multiple literal patterns. Use for snake_case/PascalCase/camelCase variants or several identifiers at once.",
    promptSnippet: "Search file contents for multiple literal patterns with fff-mcp OR logic.",
    promptGuidelines: [
      "Use fff_multi_grep instead of repeated fff_grep calls when searching two or more identifiers or naming variants.",
    ],
    parameters: multiGrepParameters,
    prepareArguments: cleanArguments,
    execute: (_toolCallId, params, signal, _onUpdate, ctx) => executeMcpTool("multi_grep", params, signal, ctx),
  });

  pi.on("session_shutdown", () => {
    for (const client of clients.values()) {
      client.stop();
    }

    clients.clear();
  });
}
