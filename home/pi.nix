{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  piNpmCacheDir = "${homeDir}/.local/share/pi/npm-cache";
  xdgConfigHome = config.xdg.configHome;
  xdgDataHome = config.xdg.dataHome;
  xdgCacheHome = config.xdg.cacheHome;
  xdgStateHome = "${homeDir}/.local/state";
  mcporterVersion = "0.10.1";
  mcporter = pkgs.writeShellApplication {
    name = "mcporter";
    runtimeInputs = [ pkgs.nodejs_24 ];
    text = ''
      export npm_config_cache="''${npm_config_cache:-$HOME/.local/share/pi/npm-cache/mcporter}"
      export npm_config_update_notifier="false"
      exec ${pkgs.nodejs_24}/bin/npx -y --registry https://registry.npmjs.org mcporter@${mcporterVersion} "$@"
    '';
  };

  mcporterServers = {
    chrome-devtools = {
      command = "${pkgs.nodejs_24}/bin/npx";
      args = [
        "-y"
        "--registry"
        "https://registry.npmjs.org"
        "chrome-devtools-mcp@0.23.0"
        "--autoConnect"
      ];
      env.npm_config_cache = "${piNpmCacheDir}/chrome-devtools";
      lifecycle = "keep-alive";
    };

    playwright = {
      command = "${pkgs.nodejs_24}/bin/npx";
      args = [
        "-y"
        "--registry"
        "https://registry.npmjs.org"
        "@playwright/mcp@0.0.71"
        "--isolated"
        "--output-dir"
        "${homeDir}/.local/share/pi/playwright-mcp"
      ];
      cwd = homeDir;
      env.npm_config_cache = "${piNpmCacheDir}/playwright";
      lifecycle = "keep-alive";
    };

    figma-mcp = {
      command = "${pkgs.bash}/bin/bash";
      args = [
        "-lc"
        ''
          set -euo pipefail

          security_bin="/usr/bin/security"
          if [[ ! -x "$security_bin" ]]; then
            echo "macOS security CLI not found; cannot read PIPARO_FIGMA_API_KEY from Keychain" >&2
            exit 1
          fi

          keychain_account="''${USER:-$(id -un)}"
          PIPARO_FIGMA_API_KEY="$("$security_bin" find-generic-password -a "$keychain_account" -s PIPARO_FIGMA_API_KEY -w)"
          export PIPARO_FIGMA_API_KEY

          FIGMA_API_KEY="$PIPARO_FIGMA_API_KEY"
          export FIGMA_API_KEY

          exec ${pkgs.nodejs_24}/bin/npx -y --registry https://registry.npmjs.org figma-mcp@0.1.4
        ''
      ];
      env.npm_config_cache = "${piNpmCacheDir}/figma-mcp";
      lifecycle = "keep-alive";
    };
  };

  mcporterConfig = {
    mcpServers = mcporterServers;
    imports = [ ];
  };

  mcporterBridgeConfig = {
    command = "${mcporter}/bin/mcporter";
    args = [ ];
    configPath = "${xdgConfigHome}/mcporter/mcporter.json";
    env = {
      npm_config_cache = "${piNpmCacheDir}/mcporter";
      XDG_CONFIG_HOME = xdgConfigHome;
      XDG_DATA_HOME = xdgDataHome;
      XDG_CACHE_HOME = xdgCacheHome;
      XDG_STATE_HOME = xdgStateHome;
    };
    staticServers = builtins.attrNames mcporterServers;
    startupDelayMs = 250;
    listTimeoutMs = 120000;
    requestTimeoutMs = 120000;
    maxTextBytes = 50 * 1024;
    maxTextLines = 2000;
    fffWarmupAttempts = 6;
    fffWarmupBaseDelayMs = 500;
    fff = {
      command = "/etc/profiles/per-user/${config.home.username}/bin/fff-mcp";
      args = [ "--no-update-check" ];
      lifecycle = "keep-alive";
      configBaseDir = "${xdgStateHome}/pi/mcporter-fff";
    };
  };

  piManagedSettings = {
    lastChangelogVersion = "0.72.0";
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.3-codex";
    enabledModels = [
      "openai-codex/gpt-5.3-codex"
      "openai-codex/gpt-5.4-mini"
      "openai-codex/gpt-5.5"
      "commandcode/deepseek/deepseek-v4-pro"
      "commandcode/deepseek/deepseek-v4-flash"
    ];
    extensions = [
      "/Users/patwoz/dev/Personal/pi/pi-commandcode-provider/index.ts"
    ];
    hideThinkingBlock = true;
    defaultThinkingLevel = "xhigh";
    transport = "websocket-cached";
    quietStartup = false;
  };
in
{
  home = {
    packages = [ mcporter ];

    sessionVariables = {
      PI_OFFLINE = "1";
      PI_SKIP_VERSION_CHECK = "1";
    };

    file = {
      ".pi/agent/extensions/opencode-bridge.js" = {
        force = true;
        source = ./files/pi/agent/extensions/opencode-bridge.js;
      };

      ".pi/agent/extensions/mcporter-bridge" = {
        force = true;
        source = ./files/pi/agent/extensions/mcporter-bridge;
      };

      ".pi/agent/mcporter-bridge.json" = {
        force = true;
        text = builtins.toJSON mcporterBridgeConfig;
      };
    };

    activation.piRemoveLegacyMcpBridge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f \
        "$HOME/.pi/agent/extensions/fff-mcp.js" \
        "$HOME/.pi/agent/extensions/mcp-bridge.js" \
        "$HOME/.pi/agent/mcp.json"
    '';

    activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PI_SETTINGS="$HOME/.pi/agent/settings.json"
      export PI_MANAGED_SETTINGS='${builtins.toJSON piManagedSettings}'

      mkdir -p "$(dirname "$PI_SETTINGS")"

      ${pkgs.python3}/bin/python3 <<'PY'
      import json
      import os
      import pathlib
      import tempfile

      path = pathlib.Path(os.environ["PI_SETTINGS"])
      managed = json.loads(os.environ["PI_MANAGED_SETTINGS"])
      mode = 0o600
      data = {}

      if path.exists():
          mode = path.stat().st_mode & 0o777
          try:
              with path.open() as handle:
                  data = json.load(handle)
          except (OSError, json.JSONDecodeError):
              data = {}

      if not isinstance(data, dict):
          data = {}

      data.update(managed)

      with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as handle:
          json.dump(data, handle, indent=2)
          handle.write("\n")
          temp_path = pathlib.Path(handle.name)

      os.chmod(temp_path, mode)
      os.replace(temp_path, path)
      PY
    '';
  };

  xdg.configFile."mcporter/mcporter.json" = {
    force = true;
    text = builtins.toJSON mcporterConfig;
  };
}
