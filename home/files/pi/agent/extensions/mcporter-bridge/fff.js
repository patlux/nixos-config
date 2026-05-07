import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  callTool,
  cleanArguments,
  contentToText,
  defaultFffWarmupAttempts,
  defaultFffWarmupBaseDelayMs,
  delay,
  expandUserPath,
  expandValue,
  findGitRoot,
  formatToolResult,
  maxContextLimit,
  maxResultsLimit,
  stableHash,
} from "./shared.js";

const fffFindFilesParameters = {
  type: "object",
  properties: {
    query: {
      type: "string",
      description: "Fuzzy file name query. Keep it short: 1-2 terms.",
    },
    maxResults: {
      type: "number",
      description: `Maximum results. Default from fff-mcp, clamped to ${maxResultsLimit}.`,
    },
    cursor: {
      type: "string",
      description: "Cursor from a previous fff_find_files result.",
    },
  },
  required: ["query"],
  additionalProperties: false,
};

const fffGrepParameters = {
  type: "object",
  properties: {
    query: {
      type: "string",
      description: "Content search query with optional constraints, e.g. '*.nix piManagedSettings'. Prefer bare identifiers.",
    },
    maxResults: {
      type: "number",
      description: `Maximum matching lines. Default from fff-mcp, clamped to ${maxResultsLimit}.`,
    },
    cursor: {
      type: "string",
      description: "Cursor from a previous fff_grep result.",
    },
    output_mode: {
      type: "string",
      description: "Output format. Usually omit this and use fff-mcp's default content mode.",
    },
  },
  required: ["query"],
  additionalProperties: false,
};

const fffMultiGrepParameters = {
  type: "object",
  properties: {
    patterns: {
      type: "array",
      items: { type: "string" },
      description: "Patterns to match with OR logic. Include naming variants together.",
    },
    constraints: {
      type: "string",
      description: "File constraints, e.g. '*.{ts,tsx} !test/'. Prefer broad constraints.",
    },
    context: {
      type: "number",
      description: `Context lines before/after each match. Clamped to ${maxContextLimit}.`,
    },
    maxResults: {
      type: "number",
      description: `Maximum matching lines. Default from fff-mcp, clamped to ${maxResultsLimit}.`,
    },
    cursor: {
      type: "string",
      description: "Cursor from a previous fff_multi_grep result.",
    },
    output_mode: {
      type: "string",
      description: "Output format. Usually omit this and use fff-mcp's default content mode.",
    },
  },
  required: ["patterns"],
  additionalProperties: false,
};

function makeFffConfig(config, cwd) {
  const root = findGitRoot(cwd);
  const fffConfig = config.fff ?? {};
  const baseDir = expandUserPath(fffConfig.configBaseDir ?? path.join(os.homedir(), ".local", "state", "pi", "mcporter-fff"));
  const dir = path.join(baseDir, stableHash(root));
  const configPath = path.join(dir, "mcporter.json");
  const command = expandUserPath(fffConfig.command ?? "fff-mcp");
  const args = [root, ...(Array.isArray(fffConfig.args) ? fffConfig.args.map(expandUserPath) : ["--no-update-check"])];

  const server = {
    command,
    args,
    cwd: root,
    lifecycle: fffConfig.lifecycle ?? "keep-alive",
  };

  if (fffConfig.env && typeof fffConfig.env === "object") {
    server.env = expandValue(fffConfig.env);
  }

  const data = {
    mcpServers: {
      fff: server,
    },
    imports: [],
  };
  const text = `${JSON.stringify(data, null, 2)}\n`;

  fs.mkdirSync(dir, { recursive: true });
  if (!fs.existsSync(configPath) || fs.readFileSync(configPath, "utf8") !== text) {
    fs.writeFileSync(configPath, text, { mode: 0o600 });
  }

  return { root, configPath };
}

function isFffColdResult(result) {
  const text = contentToText(result?.content).trim();
  return /\b0 indexed\b/.test(text) || text === "0 matches.";
}

async function executeFffTool(config, warmRoots, configPaths, mcpToolName, params, signal, ctx) {
  const args = cleanArguments(params);
  const { root, configPath } = makeFffConfig(config, ctx.cwd);
  configPaths.set(root, configPath);

  const attempts = config.fffWarmupAttempts ?? defaultFffWarmupAttempts;
  const baseDelayMs = config.fffWarmupBaseDelayMs ?? defaultFffWarmupBaseDelayMs;
  let result;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    result = await callTool(config, configPath, "fff", mcpToolName, args, ctx, signal);
    if (result?.isError) {
      throw new Error(contentToText(result.content) || `fff-mcp ${mcpToolName} failed`);
    }

    if (warmRoots.has(root) || !isFffColdResult(result)) {
      warmRoots.add(root);
      return formatToolResult(result, config, {
        server: "fff",
        tool: mcpToolName,
        via: "mcporter",
        basePath: root,
        configPath,
      });
    }

    await delay(baseDelayMs * (attempt + 1), signal);
  }

  return formatToolResult(result, config, {
    server: "fff",
    tool: mcpToolName,
    via: "mcporter",
    basePath: root,
    configPath,
    warm: false,
  });
}

export function registerFffTools(pi, config, registeredTools, warmRoots, configPaths) {
  if (registeredTools.has("fff_find_files")) {
    return;
  }

  pi.registerTool({
    name: "fff_find_files",
    label: "FFF Find Files",
    description: "FFF MCP fuzzy file-name search via MCPorter. Use to find files/modules by name; not for searching file contents.",
    promptSnippet: "Search file names quickly with fff-mcp through MCPorter frecency ranking.",
    promptGuidelines: ["Use fff_find_files when looking for a file or module by name in the current git repo; keep queries short."],
    parameters: fffFindFilesParameters,
    prepareArguments: cleanArguments,
    execute: (_toolCallId, params, signal, _onUpdate, ctx) => executeFffTool(config, warmRoots, configPaths, "find_files", params, signal, ctx),
  });

  pi.registerTool({
    name: "fff_grep",
    label: "FFF Grep",
    description: "FFF MCP content search via MCPorter. Default search tool for identifiers, definitions, usages, TODOs, and code patterns. Supports inline constraints like '*.nix piManagedSettings', 'src/ query', '!test/ query'.",
    promptSnippet: "Search file contents with fff-mcp through MCPorter; prefer bare identifiers and broad constraints.",
    promptGuidelines: [
      "Use fff_grep before built-in grep/find or shell rg when searching file contents in a git-indexed repo.",
      "Use fff_grep with one bare identifier or simple literal pattern; after two grep calls, read a top result instead of searching more.",
    ],
    parameters: fffGrepParameters,
    prepareArguments: cleanArguments,
    execute: (_toolCallId, params, signal, _onUpdate, ctx) => executeFffTool(config, warmRoots, configPaths, "grep", params, signal, ctx),
  });

  pi.registerTool({
    name: "fff_multi_grep",
    label: "FFF Multi Grep",
    description: "FFF MCP content search via MCPorter for OR logic across multiple literal patterns. Use for snake_case/PascalCase/camelCase variants or several identifiers at once.",
    promptSnippet: "Search file contents for multiple literal patterns with fff-mcp through MCPorter OR logic.",
    promptGuidelines: ["Use fff_multi_grep instead of repeated fff_grep calls when searching two or more identifiers or naming variants."],
    parameters: fffMultiGrepParameters,
    prepareArguments: cleanArguments,
    execute: (_toolCallId, params, signal, _onUpdate, ctx) => executeFffTool(config, warmRoots, configPaths, "multi_grep", params, signal, ctx),
  });

  registeredTools.add("fff_find_files");
  registeredTools.add("fff_grep");
  registeredTools.add("fff_multi_grep");
}
