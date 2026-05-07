{ lib, ... }:

{
  xdg.configFile = {
    "agents/AGENTS.md" = {
      force = true;
      source = ./files/agents/AGENTS.md;
    };

    "agents/TYPESCRIPT.md" = {
      force = true;
      source = ./files/agents/TYPESCRIPT.md;
    };

    "opencode/AGENTS.md" = {
      force = true;
      source = ./files/agents/AGENTS.md;
    };
  };

  home = {
    file = {
      ".claude/CLAUDE.md" = {
        force = true;
        text = ''
          # Claude Code Global Adapter

          Read and follow the agent-neutral guidance in `/Users/patwoz/.config/agents/AGENTS.md`.
        '';
      };

      ".pi/agent/AGENTS.md" = {
        force = true;
        text = ''
          # Pi Coding Agent Adapter

          Read and follow the agent-neutral guidance in `/Users/patwoz/.config/agents/AGENTS.md`.
        '';
      };
    };

    activation.removeLegacyAgentDocs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for path in "$HOME/.pi/agent/TYPESCRIPT.md" "$HOME/.pi/agent/CLICKUP.md"; do
        if [[ -f "$path" && ! -L "$path" ]]; then
          case "$path" in
            */TYPESCRIPT.md)
              if grep -q 'Never use `any`' "$path"; then
                rm -f "$path"
              fi
              ;;
            */CLICKUP.md)
              if grep -q 'PIPARO_CLICKUP_API_KEY' "$path"; then
                rm -f "$path"
              fi
              ;;
          esac
        fi
      done
    '';
  };
}
