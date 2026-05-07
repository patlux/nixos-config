import os from "node:os";
import path from "node:path";
import { registerFffTools } from "./fff.js";
import {
  callTool,
  cleanArguments,
  defaultStartupDelayMs,
  defaultTimeoutMs,
  expandUserPath,
  formatToolResult,
  normalizeSchema,
  readBridgeConfig,
  runMcporter,
  runMcporterText,
  sanitizeToolName,
} from "./shared.js";

export default function mcporterBridge(pi) {
  const config = readBridgeConfig();
  const staticConfigPath = expandUserPath(config.configPath ?? path.join(os.homedir(), ".config", "mcporter", "mcporter.json"));
  const staticServers = Array.isArray(config.staticServers) ? config.staticServers : [];
  const serverStates = new Map(staticServers.map((server) => [server, { name: server, status: "scheduled", tools: [] }]));
  const registeredTools = new Set();
  const fffWarmRoots = new Set();
  const fffConfigPaths = new Map();
  let startTimer = undefined;
  let startPromise = undefined;

  function registerStaticTool(server, tool) {
    const piToolName = `${sanitizeToolName(server)}__${sanitizeToolName(tool.name)}`;
    if (registeredTools.has(piToolName)) {
      return;
    }

    pi.registerTool({
      name: piToolName,
      label: `${server}: ${tool.name}`,
      description: `[${server} MCP via MCPorter] ${tool.description ?? tool.name}`,
      parameters: normalizeSchema(tool.inputSchema),
      executionMode: "sequential",
      async execute(_toolCallId, params, signal, _onUpdate, ctx) {
        const result = await callTool(config, staticConfigPath, server, tool.name, cleanArguments(params), ctx, signal);
        return formatToolResult(result, config, {
          server,
          tool: tool.name,
          via: "mcporter",
          isError: result?.isError === true,
        });
      },
    });

    registeredTools.add(piToolName);
  }

  async function discoverServer(server, ctx) {
    const state = serverStates.get(server) ?? { name: server, status: "scheduled", tools: [] };
    serverStates.set(server, state);
    state.status = "starting";
    state.startedAt = Date.now();
    state.error = undefined;

    try {
      const result = await runMcporter(config, ["list", server, "--config", staticConfigPath, "--json"], {
        cwd: ctx.cwd,
        timeoutMs: config.listTimeoutMs ?? defaultTimeoutMs,
      });

      if (result.status && result.status !== "ok") {
        throw new Error(result.issue?.rawMessage ?? result.error ?? `${server} status: ${result.status}`);
      }

      const tools = Array.isArray(result.tools) ? result.tools : [];
      for (const tool of tools) {
        registerStaticTool(server, tool);
      }

      state.status = "ready";
      state.tools = tools;
      state.readyAt = Date.now();
    } catch (error) {
      state.status = "error";
      state.finishedAt = Date.now();
      state.error = error instanceof Error ? error.message : String(error);
      console.warn(`Failed to discover ${server} through MCPorter: ${state.error}`);
    }
  }

  function discoverServers(ctx) {
    if (startPromise) {
      return startPromise;
    }

    startPromise = Promise.all(staticServers.map((server) => discoverServer(server, ctx))).finally(() => {
      startPromise = undefined;
    });

    return startPromise;
  }

  function scheduleDiscovery(ctx) {
    if (startTimer) {
      clearTimeout(startTimer);
    }

    const delayMs = config.startupDelayMs ?? defaultStartupDelayMs;
    startTimer = setTimeout(() => {
      startTimer = undefined;
      discoverServers(ctx).catch((error) => {
        console.warn(`MCPorter discovery failed: ${error instanceof Error ? error.message : String(error)}`);
      });
    }, delayMs);
  }

  function formatServerState(state) {
    if (state.status === "ready") {
      const elapsed = state.readyAt && state.startedAt ? ` in ${((state.readyAt - state.startedAt) / 1000).toFixed(1)}s` : "";
      return `${state.name}: ${state.tools.length} tools via MCPorter${elapsed}`;
    }

    if (state.status === "error") {
      return `${state.name}: error: ${state.error}`;
    }

    return `${state.name}: ${state.status}`;
  }

  async function showStatus(ctx) {
    const lines = Array.from(serverStates.values()).map(formatServerState);
    lines.unshift(`fff: MCPorter-backed dynamic git-root server (${fffWarmRoots.size} warm root${fffWarmRoots.size === 1 ? "" : "s"})`);

    try {
      const daemonStatus = await runMcporterText(config, ["daemon", "status", "--config", staticConfigPath], {
        cwd: ctx.cwd,
        timeoutMs: 15_000,
      });
      lines.push("", daemonStatus);
    } catch (error) {
      lines.push("", `MCPorter daemon status unavailable: ${error instanceof Error ? error.message : String(error)}`);
    }

    ctx.ui.notify(lines.join("\n"), "info");
  }

  async function stopDaemons(ctx) {
    const configs = new Set([staticConfigPath, ...fffConfigPaths.values()]);
    const errors = [];

    for (const configPath of configs) {
      try {
        await runMcporterText(config, ["daemon", "stop", "--config", configPath], {
          cwd: ctx.cwd,
          timeoutMs: 30_000,
        });
      } catch (error) {
        errors.push(`${configPath}: ${error instanceof Error ? error.message : String(error)}`);
      }
    }

    if (errors.length > 0) {
      ctx.ui.notify(`Some MCPorter daemons could not be stopped:\n${errors.join("\n")}`, "warning");
      return;
    }

    ctx.ui.notify("MCPorter daemons stopped", "info");
  }

  async function startNow(ctx) {
    if (startTimer) {
      clearTimeout(startTimer);
      startTimer = undefined;
    }

    await discoverServers(ctx);
    ctx.ui.notify("MCPorter server discovery complete", "info");
  }

  registerFffTools(pi, config, registeredTools, fffWarmRoots, fffConfigPaths);

  pi.on("session_start", (_event, ctx) => {
    scheduleDiscovery(ctx);
  });

  pi.registerCommand("mcporter-start", {
    description: "Discover MCPorter servers and register their tools now",
    handler: async (_args, ctx) => startNow(ctx),
  });

  pi.registerCommand("mcp-start", {
    description: "Alias for /mcporter-start",
    handler: async (_args, ctx) => startNow(ctx),
  });

  pi.registerCommand("mcporter-status", {
    description: "Show MCPorter server, tool, and daemon status",
    handler: async (_args, ctx) => showStatus(ctx),
  });

  pi.registerCommand("mcp-status", {
    description: "Alias for /mcporter-status",
    handler: async (_args, ctx) => showStatus(ctx),
  });

  pi.registerCommand("mcporter-stop", {
    description: "Stop MCPorter keep-alive daemons known to this Pi session",
    handler: async (_args, ctx) => stopDaemons(ctx),
  });

  pi.on("session_shutdown", () => {
    if (startTimer) {
      clearTimeout(startTimer);
      startTimer = undefined;
    }
  });
}
