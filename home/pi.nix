{
  lib,
  pkgs,
  ...
}:

let
  mcpServers = {
    chrome-devtools = {
      command = "${pkgs.nodejs_22}/bin/npx";
      args = [
        "-y"
        "--registry"
        "https://registry.npmjs.org"
        "chrome-devtools-mcp@0.23.0"
        "--autoConnect"
      ];
      env.npm_config_cache = "~/.local/share/pi/npm-cache/chrome-devtools";
    };

    playwright = {
      command = "${pkgs.nodejs_22}/bin/npx";
      args = [
        "-y"
        "--registry"
        "https://registry.npmjs.org"
        "@playwright/mcp@0.0.71"
      ];
      env.npm_config_cache = "~/.local/share/pi/npm-cache/playwright";
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

          exec ${pkgs.nodejs_22}/bin/npx -y --registry https://registry.npmjs.org figma-mcp@0.1.4
        ''
      ];
      env.npm_config_cache = "~/.local/share/pi/npm-cache/figma-mcp";
    };
  };
  piManagedSettings = {
    lastChangelogVersion = "0.72.0";
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.3-codex";
    enabledModels = [
      "openai-codex/gpt-5.3-codex"
      "openai-codex/gpt-5.5"
      "deepseek/deepseek-v4-flash"
      "deepseek/deepseek-v4-pro"
    ];
    hideThinkingBlock = true;
    defaultThinkingLevel = "xhigh";
    transport = "websocket-cached";
    quietStartup = false;
  };
in
{
  home = {
    sessionVariables = {
      PI_OFFLINE = "1";
      PI_SKIP_VERSION_CHECK = "1";
    };

    file = {
      ".pi/agent/extensions/opencode-bridge.js" = {
        force = true;
        source = ./files/pi/agent/extensions/opencode-bridge.js;
      };

      ".pi/agent/extensions/fff-mcp.js" = {
        force = true;
        source = ./files/pi/agent/extensions/fff-mcp.js;
      };

      ".pi/agent/extensions/mcp-bridge.js" = {
        force = true;
        source = ./files/pi/agent/extensions/mcp-bridge.js;
      };

      ".pi/agent/mcp.json" = {
        force = true;
        text = builtins.toJSON { servers = mcpServers; };
      };
    };

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
}
