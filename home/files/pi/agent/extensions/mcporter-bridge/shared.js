import { spawn } from "node:child_process";
import { createHash } from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

export const bridgeConfigPath = path.join(os.homedir(), ".pi", "agent", "mcporter-bridge.json");
export const defaultStartupDelayMs = 250;
export const defaultTimeoutMs = 120_000;
export const defaultFffWarmupAttempts = 6;
export const defaultFffWarmupBaseDelayMs = 500;
export const defaultMaxTextBytes = 50 * 1024;
export const defaultMaxTextLines = 2_000;
export const maxResultsLimit = 100;
export const maxContextLimit = 20;

export function expandUserPath(value) {
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

export function expandValue(value) {
  if (typeof value === "string") {
    return expandUserPath(value);
  }

  if (Array.isArray(value)) {
    return value.map(expandValue);
  }

  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, expandValue(item)]));
  }

  return value;
}

export function readBridgeConfig() {
  try {
    const parsed = JSON.parse(fs.readFileSync(bridgeConfigPath, "utf8"));
    return expandValue(parsed);
  } catch {
    return {};
  }
}

export function sanitizeToolName(value) {
  const sanitized = String(value).replace(/[^a-zA-Z0-9_-]/g, "_").replace(/_+/g, "_");
  return sanitized.replace(/^_+|_+$/g, "") || "tool";
}

export function normalizeSchema(schema) {
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

function getMaxTextBytes(config) {
  return Number.isFinite(config.maxTextBytes) ? config.maxTextBytes : defaultMaxTextBytes;
}

function getMaxTextLines(config) {
  return Number.isFinite(config.maxTextLines) ? config.maxTextLines : defaultMaxTextLines;
}

export function truncateText(text, config) {
  let output = String(text ?? "");
  let truncated = false;

  const maxLines = getMaxTextLines(config);
  const maxBytes = getMaxTextBytes(config);
  const lines = output.split(/\r?\n/);

  if (lines.length > maxLines) {
    output = lines.slice(0, maxLines).join("\n");
    truncated = true;
  }

  if (Buffer.byteLength(output, "utf8") > maxBytes) {
    output = Buffer.from(output, "utf8").subarray(0, maxBytes).toString("utf8");
    truncated = true;
  }

  if (truncated) {
    output += `\n\n[MCPorter output truncated to ${maxLines} lines / ${maxBytes} bytes. Narrow the query or lower maxResults.]`;
  }

  return output;
}

export function formatMcpContent(content, config) {
  if (!Array.isArray(content) || content.length === 0) {
    return [];
  }

  return content.map((item) => {
    if (item?.type === "text" && typeof item.text === "string") {
      return { type: "text", text: truncateText(item.text, config) };
    }

    if (item?.type === "resource" && item.resource?.text) {
      return { type: "text", text: truncateText(item.resource.text, config) };
    }

    if (item?.type === "image") {
      const mimeType = item.mimeType ?? "image/*";
      return { type: "text", text: `[MCP image result omitted: ${mimeType}]` };
    }

    if (item?.type === "audio") {
      const mimeType = item.mimeType ?? "audio/*";
      return { type: "text", text: `[MCP audio result omitted: ${mimeType}]` };
    }

    return { type: "text", text: truncateText(JSON.stringify(item, null, 2), config) };
  });
}

export function contentToText(content) {
  if (!Array.isArray(content)) {
    return "";
  }

  return content
    .map((item) => (item?.type === "text" && typeof item.text === "string" ? item.text : ""))
    .filter(Boolean)
    .join("\n");
}

export function delay(ms, signal) {
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

export function findGitRoot(cwd) {
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

export function stableHash(value) {
  return createHash("sha256").update(value).digest("hex").slice(0, 16);
}

function mergeEnv(config) {
  const env = {
    ...process.env,
    NO_COLOR: "1",
    npm_config_update_notifier: "false",
  };

  for (const [key, value] of Object.entries(config.env ?? {})) {
    env[key] = expandUserPath(value);
  }

  return env;
}

function runProcess(command, args, options) {
  const timeoutMs = options.timeoutMs ?? defaultTimeoutMs;

  return new Promise((resolve, reject) => {
    if (options.signal?.aborted) {
      reject(new Error("Cancelled"));
      return;
    }

    const child = spawn(command, args, {
      cwd: options.cwd ?? process.cwd(),
      env: options.env ?? process.env,
      stdio: ["ignore", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    let settled = false;

    const cleanup = () => {
      clearTimeout(timeout);
      options.signal?.removeEventListener("abort", onAbort);
    };

    const settle = (fn, value) => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      fn(value);
    };

    const timeout = setTimeout(() => {
      child.kill();
      settle(reject, new Error(`${path.basename(command)} timed out after ${timeoutMs}ms`));
    }, timeoutMs);

    const onAbort = () => {
      child.kill();
      settle(reject, new Error("Cancelled"));
    };

    options.signal?.addEventListener("abort", onAbort, { once: true });

    child.stdout.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });

    child.stderr.setEncoding("utf8");
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });

    child.on("error", (error) => settle(reject, error));
    child.on("close", (code, signal) => {
      settle(resolve, {
        code,
        signal,
        stdout,
        stderr,
      });
    });
  });
}

function parseJsonOutput(stdout, stderr) {
  const trimmed = stdout.trim();
  if (!trimmed) {
    throw new Error(stderr.trim() || "MCPorter returned no JSON output");
  }

  try {
    return JSON.parse(trimmed);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Failed to parse MCPorter JSON output: ${message}\n${trimmed.slice(0, 2_000)}`);
  }
}

function getPayloadError(payload, stderr) {
  if (typeof payload?.error === "string") {
    return payload.error;
  }

  const text = contentToText(payload?.content);
  if (text) {
    return text;
  }

  if (payload?.issue?.rawMessage) {
    return payload.issue.rawMessage;
  }

  return stderr.trim() || JSON.stringify(payload ?? {}, null, 2);
}

export async function runMcporter(config, args, options = {}) {
  const command = expandUserPath(config.command ?? "mcporter");
  const baseArgs = Array.isArray(config.args) ? config.args.map(expandUserPath) : [];
  const result = await runProcess(command, [...baseArgs, ...args], {
    cwd: options.cwd ?? process.cwd(),
    env: mergeEnv(config),
    signal: options.signal,
    timeoutMs: options.timeoutMs ?? defaultTimeoutMs,
  });

  const payload = parseJsonOutput(result.stdout, result.stderr);
  if (result.code !== 0) {
    throw new Error(getPayloadError(payload, result.stderr));
  }

  return payload;
}

export async function runMcporterText(config, args, options = {}) {
  const command = expandUserPath(config.command ?? "mcporter");
  const baseArgs = Array.isArray(config.args) ? config.args.map(expandUserPath) : [];
  const result = await runProcess(command, [...baseArgs, ...args], {
    cwd: options.cwd ?? process.cwd(),
    env: mergeEnv(config),
    signal: options.signal,
    timeoutMs: options.timeoutMs ?? defaultTimeoutMs,
  });

  if (result.code !== 0) {
    throw new Error(result.stderr.trim() || result.stdout.trim() || `${path.basename(command)} exited with code ${result.code}`);
  }

  return result.stdout.trim() || result.stderr.trim();
}

export function cleanArguments(args) {
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
    cleaned.maxResults = Math.max(1, Math.min(maxResultsLimit, Math.floor(cleaned.maxResults)));
  }

  if (typeof cleaned.context === "number") {
    cleaned.context = Math.max(0, Math.min(maxContextLimit, Math.floor(cleaned.context)));
  }

  if (typeof cleaned.patterns === "string") {
    cleaned.patterns = cleaned.patterns
      .split(/[\n,]/)
      .map((pattern) => pattern.trim())
      .filter(Boolean);
  }

  return cleaned;
}

export async function callTool(config, configPath, server, tool, args, ctx, signal) {
  const timeoutMs = config.requestTimeoutMs ?? defaultTimeoutMs;
  return runMcporter(
    config,
    [
      "call",
      `${server}.${tool}`,
      "--config",
      configPath,
      "--output",
      "json",
      "--timeout",
      String(timeoutMs),
      "--args",
      JSON.stringify(args ?? {}),
    ],
    {
      cwd: ctx.cwd,
      signal,
      timeoutMs: timeoutMs + 10_000,
    },
  );
}

export function formatToolResult(result, config, details) {
  const content = formatMcpContent(result?.content, config);

  return {
    content: content.length > 0 ? content : [{ type: "text", text: truncateText(JSON.stringify(result ?? {}, null, 2), config) }],
    details,
  };
}
