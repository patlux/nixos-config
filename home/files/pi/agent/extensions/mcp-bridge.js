import { spawn } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const configPath = path.join(os.homedir(), ".pi", "agent", "mcp.json");
const defaultInitTimeoutMs = 120_000;
const defaultRequestTimeoutMs = 60_000;
const defaultStartupDelayMs = 250;

function expandUserPath(value) {
  if (typeof value !== "string") {
    return value;
  }

  if (value === "~") {
    return os.homedir();
  }

  if (value.startsWith("~/")) {
    return path.join(os.homedir(), value.slice(2));
  }

  return value.replaceAll("$HOME", os.homedir());
}

function readConfig() {
  try {
    const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
    const servers = config?.servers;
    return servers && typeof servers === "object" && !Array.isArray(servers) ? servers : {};
  } catch {
    return {};
  }
}

function sanitizeToolName(value) {
  const sanitized = value.replace(/[^a-zA-Z0-9_-]/g, "_").replace(/_+/g, "_");
  return sanitized.replace(/^_+|_+$/g, "") || "tool";
}

function normalizeSchema(schema) {
  if (!schema || typeof schema !== "object" || Array.isArray(schema)) {
    return {
      type: "object",
      properties: {},
      additionalProperties: true,
    };
  }

  return {
    ...schema,
    type: schema.type ?? "object",
    properties: schema.properties ?? {},
  };
}

function formatMcpContent(content) {
  if (!Array.isArray(content) || content.length === 0) {
    return [];
  }

  return content.map((item) => {
    if (item?.type === "text" && typeof item.text === "string") {
      return { type: "text", text: item.text };
    }

    if (item?.type === "resource" && item.resource?.text) {
      return { type: "text", text: item.resource.text };
    }

    if (item?.type === "image") {
      const mimeType = item.mimeType ?? "image/*";
      return { type: "text", text: `[MCP image result omitted: ${mimeType}]` };
    }

    if (item?.type === "audio") {
      const mimeType = item.mimeType ?? "audio/*";
      return { type: "text", text: `[MCP audio result omitted: ${mimeType}]` };
    }

    return { type: "text", text: JSON.stringify(item, null, 2) };
  });
}

class McpServer {
  constructor(name, definition) {
    this.name = name;
    this.definition = definition;
    this.nextId = 1;
    this.pending = new Map();
    this.buffer = "";
    this.stderr = [];
    this.tools = [];
    this.error = undefined;
    this.process = undefined;
  }

  async start() {
    const command = expandUserPath(this.definition.command);
    const args = Array.isArray(this.definition.args) ? this.definition.args.map(expandUserPath) : [];
    const env = { ...process.env };

    for (const [key, value] of Object.entries(this.definition.env ?? {})) {
      env[key] = expandUserPath(value);
    }

    this.process = spawn(command, args, {
      cwd: expandUserPath(this.definition.cwd) ?? process.cwd(),
      env,
      stdio: ["pipe", "pipe", "pipe"],
    });

    this.process.stdout.setEncoding("utf8");
    this.process.stdout.on("data", (chunk) => this.handleStdout(chunk));
    this.process.stderr.setEncoding("utf8");
    this.process.stderr.on("data", (chunk) => this.handleStderr(chunk));
    this.process.on("exit", (code, signal) => {
      const message = signal ? `exited with signal ${signal}` : `exited with code ${code}`;
      this.rejectAll(new Error(`${this.name} MCP server ${message}`));
    });
    this.process.on("error", (error) => this.rejectAll(error));

    await this.request(
      "initialize",
      {
        protocolVersion: "2025-03-26",
        capabilities: {},
        clientInfo: {
          name: "pi-mcp-bridge",
          version: "1.0.0",
        },
      },
      this.definition.initTimeoutMs ?? defaultInitTimeoutMs,
    );

    this.notify("notifications/initialized", {});
    this.tools = await this.listTools();
  }

  handleStdout(chunk) {
    this.buffer += chunk;

    while (true) {
      const newline = this.buffer.indexOf("\n");
      if (newline === -1) {
        return;
      }

      const line = this.buffer.slice(0, newline).trim();
      this.buffer = this.buffer.slice(newline + 1);

      if (!line) {
        continue;
      }

      try {
        this.handleMessage(JSON.parse(line));
      } catch (error) {
        this.error = `Invalid JSON from ${this.name}: ${error instanceof Error ? error.message : String(error)}`;
      }
    }
  }

  handleStderr(chunk) {
    for (const line of chunk.split("\n")) {
      const trimmed = line.trim();
      if (trimmed) {
        this.stderr.push(trimmed);
      }
    }

    this.stderr = this.stderr.slice(-20);
  }

  handleMessage(message) {
    if (Array.isArray(message)) {
      for (const item of message) {
        this.handleMessage(item);
      }
      return;
    }

    if (message && Object.prototype.hasOwnProperty.call(message, "id") && message.method) {
      this.send({
        jsonrpc: "2.0",
        id: message.id,
        error: {
          code: -32601,
          message: `Pi MCP bridge does not implement client method ${message.method}`,
        },
      });
      return;
    }

    if (!message || !Object.prototype.hasOwnProperty.call(message, "id")) {
      return;
    }

    const pending = this.pending.get(message.id);
    if (!pending) {
      return;
    }

    this.pending.delete(message.id);
    clearTimeout(pending.timeout);

    if (message.error) {
      pending.reject(new Error(message.error.message ?? JSON.stringify(message.error)));
      return;
    }

    pending.resolve(message.result);
  }

  send(message) {
    if (!this.process?.stdin.writable) {
      throw new Error(`${this.name} MCP server is not running`);
    }

    this.process.stdin.write(`${JSON.stringify(message)}\n`);
  }

  request(method, params = {}, timeoutMs = defaultRequestTimeoutMs, signal) {
    const id = this.nextId++;

    return new Promise((resolve, reject) => {
      if (signal?.aborted) {
        reject(new Error(`${method} cancelled`));
        return;
      }

      const onAbort = () => {
        this.pending.delete(id);
        reject(new Error(`${method} cancelled`));
      };

      const timeout = setTimeout(() => {
        signal?.removeEventListener("abort", onAbort);
        this.pending.delete(id);
        const stderr = this.stderr.length > 0 ? `\n${this.stderr.join("\n")}` : "";
        reject(new Error(`${this.name} MCP request ${method} timed out after ${timeoutMs}ms${stderr}`));
      }, timeoutMs);

      this.pending.set(id, {
        resolve: (result) => {
          signal?.removeEventListener("abort", onAbort);
          resolve(result);
        },
        reject: (error) => {
          signal?.removeEventListener("abort", onAbort);
          reject(error);
        },
        timeout,
      });

      signal?.addEventListener("abort", onAbort, { once: true });

      try {
        this.send({ jsonrpc: "2.0", id, method, params });
      } catch (error) {
        clearTimeout(timeout);
        this.pending.delete(id);
        signal?.removeEventListener("abort", onAbort);
        reject(error);
      }
    });
  }

  notify(method, params = {}) {
    this.send({ jsonrpc: "2.0", method, params });
  }

  async listTools() {
    const tools = [];
    let cursor = undefined;

    do {
      const result = await this.request("tools/list", cursor ? { cursor } : {});
      tools.push(...(Array.isArray(result?.tools) ? result.tools : []));
      cursor = result?.nextCursor;
    } while (cursor);

    return tools;
  }

  callTool(name, args, signal) {
    return this.request(
      "tools/call",
      {
        name,
        arguments: args,
      },
      this.definition.requestTimeoutMs ?? defaultRequestTimeoutMs,
      signal,
    );
  }

  rejectAll(error) {
    this.error = error.message;

    for (const [id, pending] of this.pending.entries()) {
      clearTimeout(pending.timeout);
      pending.reject(error);
      this.pending.delete(id);
    }
  }

  stop() {
    this.rejectAll(new Error(`${this.name} MCP server stopped`));
    this.process?.kill();
  }
}

function registerServerTools(pi, server) {
  for (const tool of server.tools) {
    const piToolName = `${sanitizeToolName(server.name)}__${sanitizeToolName(tool.name)}`;
    const originalToolName = tool.name;

    pi.registerTool({
      name: piToolName,
      label: `${server.name}: ${originalToolName}`,
      description: `[${server.name} MCP] ${tool.description ?? originalToolName}`,
      parameters: normalizeSchema(tool.inputSchema),
      executionMode: "sequential",
      async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
        const result = await server.callTool(originalToolName, params, signal);
        const content = formatMcpContent(result?.content);
        const isError = result?.isError === true;

        return {
          content: content.length > 0 ? content : [{ type: "text", text: JSON.stringify(result ?? {}, null, 2) }],
          details: {
            server: server.name,
            tool: originalToolName,
            isError,
          },
        };
      },
    });
  }
}

function formatSeconds(milliseconds) {
  return `${(milliseconds / 1000).toFixed(1)}s`;
}

function getStartupDelayMs() {
  const value = Number(process.env.PI_MCP_STARTUP_DELAY_MS);
  if (Number.isFinite(value) && value >= 0) {
    return value;
  }

  return defaultStartupDelayMs;
}

function formatServerStatus(state) {
  if (state.status === "scheduled") {
    const remaining = Math.max(0, state.startAfter - Date.now());
    return `${state.server.name}: scheduled (starts in ${formatSeconds(remaining)})`;
  }

  if (state.status === "ready") {
    return `${state.server.name}: ${state.server.tools.length} tools (ready in ${formatSeconds(state.readyAt - state.startedAt)})`;
  }

  if (state.status === "error") {
    return `${state.server.name}: error after ${formatSeconds(state.finishedAt - state.startedAt)}: ${state.error}`;
  }

  if (state.status === "stopped") {
    return `${state.server.name}: stopped`;
  }

  return `${state.server.name}: starting (${formatSeconds(Date.now() - state.startedAt)})`;
}

export default function mcpBridge(pi) {
  const serverStates = [];
  const configuredServers = readConfig();
  const startupDelayMs = getStartupDelayMs();
  let shuttingDown = false;
  let startTimer = undefined;

  function startServer(state) {
    if (shuttingDown || state.status !== "scheduled") {
      return;
    }

    const { server } = state;
    state.status = "starting";
    state.startedAt = Date.now();

    state.promise = server
      .start()
      .then(() => {
        if (shuttingDown) {
          state.status = "stopped";
          server.stop();
          return;
        }

        state.status = "ready";
        state.readyAt = Date.now();
        registerServerTools(pi, server);
      })
      .catch((error) => {
        if (shuttingDown) {
          state.status = "stopped";
          return;
        }

        state.status = "error";
        state.finishedAt = Date.now();
        state.error = error instanceof Error ? error.message : String(error);
        server.error = state.error;
        console.warn(`Failed to start ${server.name} MCP server: ${state.error}`);
      });
  }

  function startServers() {
    if (startTimer) {
      clearTimeout(startTimer);
      startTimer = undefined;
    }

    for (const state of serverStates) {
      startServer(state);
    }
  }

  for (const [name, definition] of Object.entries(configuredServers)) {
    if (definition?.enabled === false) {
      continue;
    }

    const server = new McpServer(name, definition);
    const now = Date.now();
    const state = {
      server,
      status: "scheduled",
      scheduledAt: now,
      startAfter: now + startupDelayMs,
      startedAt: undefined,
      readyAt: undefined,
      finishedAt: undefined,
      error: undefined,
      promise: undefined,
    };

    serverStates.push(state);
  }

  startTimer = setTimeout(startServers, startupDelayMs);

  pi.registerCommand("mcp-start", {
    description: "Start MCP bridge servers now",
    handler: async (_args, ctx) => {
      startServers();
      ctx.ui.notify("MCP bridge servers are starting", "info");
    },
  });

  pi.registerCommand("mcp-status", {
    description: "Show MCP bridge server and tool status",
    handler: async (_args, ctx) => {
      const lines = serverStates.map(formatServerStatus);
      ctx.ui.notify(lines.length > 0 ? lines.join("\n") : "No MCP servers configured", "info");
    },
  });

  pi.on("session_shutdown", async () => {
    shuttingDown = true;

    if (startTimer) {
      clearTimeout(startTimer);
      startTimer = undefined;
    }

    for (const state of serverStates) {
      state.server.stop();
    }

    await Promise.allSettled(serverStates.map((state) => state.promise).filter(Boolean));
  });
}
