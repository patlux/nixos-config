{
  lib,
  pkgs,
  ...
}:

let
  agentGuidanceTemplate = builtins.readFile ./files/agent/AGENTS.md;
  piManagedSettings = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.4";
    hideThinkingBlock = true;
  };
in
{
  home = {
    file = {
      ".pi/agent/AGENTS.md" = {
        force = true;
        text =
          builtins.replaceStrings [ "__TYPESCRIPT_PATH__" ] [ "~/.pi/agent/TYPESCRIPT.md" ]
            agentGuidanceTemplate;
      };

      ".pi/agent/TYPESCRIPT.md" = {
        force = true;
        source = ./files/agent/TYPESCRIPT.md;
      };

      ".pi/agent/extensions/opencode-bridge.js" = {
        force = true;
        source = ./files/pi/agent/extensions/opencode-bridge.js;
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
