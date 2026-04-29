{
  config,
  lib,
  pkgs,
  ...
}:

let
  fffMcpBin = "/etc/profiles/per-user/${config.home.username}/bin/fff-mcp";
  claudeConfig = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    model = "opus";
    enabledPlugins = {
      "playground@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
    permissions = {
      additionalDirectories = [
        "~/dev"
        "~/.agent-browser"
        "/var/folders"
        "/private/var/folders"
      ];
      allow = [
        "Read(.)"
        "Edit(.)"
        "Write(.)"
        "Read(~/dev/**)"
        "Edit(~/dev/**)"
        "Write(~/dev/**)"
        "Read(~/.agent-browser/**)"
        "Edit(~/.agent-browser/**)"
        "Write(~/.agent-browser/**)"
        "Read(/var/folders/**)"
        "Edit(/var/folders/**)"
        "Write(/var/folders/**)"
        "Read(/private/var/folders/**)"
        "Edit(/private/var/folders/**)"
        "Write(/private/var/folders/**)"
        "Bash(npx tsc:*)"
        "Bash(npx eslint:*)"
        "Bash(npx vitest:*)"
        "Bash(pnpm lint:*)"
        "Bash(pnpm typecheck:*)"
        "Bash(pnpm test:*)"
        "Bash(pnpm build:*)"
        "Bash(npx expo export:web:*)"
        "Bash(ls:*)"
        "Bash(pwd:*)"
        "Bash(mkdir:*)"
        "Bash(cp:*)"
        "Bash(mv:*)"
        "Bash(make fmt:*)"
        "Bash(make lint:*)"
        "Bash(make check:*)"
        "Bash(make preview:*)"
        "Bash(nix fmt:*)"
        "Bash(nix flake check:*)"
        "Bash(nix run nixpkgs#statix:*)"
        "Bash(git add:*)"
        "Bash(git commit:*)"
        "Bash(git:*)"
        "Bash(bun run:*)"
        "Bash(python3:*)"
        "Bash(npx agent-browser:*)"
        "mcp__fff"
        "WebFetch"
        "WebSearch"
        "mcp__chrome-devtools"
      ];
      deny = [
        "Read(//**)"
        "Edit(//**)"
        "Write(//**)"
      ];
    };
  };

  chromeDevtoolsMcp = {
    command = "npx";
    args = [
      "-y"
      "--registry"
      "https://registry.npmjs.org"
      "chrome-devtools-mcp@latest"
      "--autoConnect"
    ];
  };

  fffMcp = {
    command = fffMcpBin;
    args = [ ];
  };
in
{
  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON claudeConfig;
  };

  # Preserve Claude's mutable state in ~/.claude.json while enforcing these MCP entries.
  home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export CLAUDE_JSON="$HOME/.claude.json"
    export CLAUDE_MCP_SERVERS='${
      builtins.toJSON {
        chrome-devtools = chromeDevtoolsMcp;
        fff = fffMcp;
      }
    }'

    ${pkgs.python3}/bin/python3 <<'PY'
    import json
    import os
    import pathlib
    import tempfile

    path = pathlib.Path(os.environ["CLAUDE_JSON"])
    servers = json.loads(os.environ["CLAUDE_MCP_SERVERS"])

    mode = 0o600
    data = {}

    if path.exists():
        mode = path.stat().st_mode & 0o777
        with path.open() as handle:
            data = json.load(handle)

    if not isinstance(data, dict):
        data = {}

    mcp_servers = data.get("mcpServers")
    if not isinstance(mcp_servers, dict):
        mcp_servers = {}

    for name, server in servers.items():
        mcp_servers[name] = server

    data["mcpServers"] = mcp_servers

    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as handle:
        json.dump(data, handle, indent=2)
        handle.write("\n")
        temp_path = pathlib.Path(handle.name)

    os.chmod(temp_path, mode)
    os.replace(temp_path, path)
    PY
  '';
}
