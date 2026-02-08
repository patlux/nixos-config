{ ... }:

let
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";

    permission = {
      external_directory = {
        "*" = "ask";
        "~/dev/*" = "allow";
        "/tmp/*" = "allow";
      };

      read = {
        "*" = "allow";

        # Explicit .env policy (OpenCode also denies these by default)
        "*.env" = "deny";
        "*.env.*" = "deny";
        "*.env.example" = "allow";

        # OpenCode credential store
        "*/.local/share/opencode/auth.json" = "deny";

        # Common secret files
        "*/.netrc" = "deny";
        "*/.npmrc" = "deny";
        "*/.pypirc" = "deny";

        # Cloud / container credentials
        "*/.aws/credentials" = "deny";
        "*/.aws/config" = "deny";
        "*/.docker/config.json" = "deny";

        # SSH keys and configs (conservative)
        "*/.ssh/id_*" = "deny";
        "*/.ssh/*_rsa" = "deny";
        "*/.ssh/*_ed25519" = "deny";

        # GPG material (conservative)
        "*/.gnupg/*" = "deny";

        # Private key/cert containers
        "*.pem" = "deny";
        "*.key" = "deny";
        "*.p12" = "deny";
        "*.pfx" = "deny";
        "*.jks" = "deny";
      };
    };

    plugin = [
      "opencode-anthropic-auth@latest"
      "opencode-openai-codex-auth"
    ];

    provider = {
      openai = {
        options = {
          reasoningEffort = "medium";
          reasoningSummary = "auto";
          textVerbosity = "medium";
          include = [ "reasoning.encrypted_content" ];
          store = false;
        };

        # Intentionally NOT including `models = { ... }` to keep config small.
      };
    };
  };
in
{
  xdg.configFile."opencode/opencode.json" = {
    force = true;
    text = builtins.toJSON opencodeConfig;
  };

  # Global AGENTS.md - personal coding standards across all projects
  xdg.configFile."opencode/AGENTS.md" = {
    force = true;
    text = ''
      # Personal Coding Standards

      ## Security & Privacy
      - NEVER read or suggest reading: .env files, ~/.ssh/*, ~/.aws/credentials, secret files
      - When working with configs, assume .env.example is the template, never the real .env
      - Don't commit secrets - if you see API keys in code, warn immediately

      ## Nix/NixOS Specific
      - Prefer declarative configuration in .nix files over imperative changes
      - When suggesting packages: use nixpkgs names, not just 'npm install'
      - For macOS (darwin): use homebrew.nix for casks, not 'brew install'
      - Test with 'darwin-rebuild switch' or 'nixos-rebuild switch' after changes

      ## Git Workflow
      - Write commit messages in present tense: "Add feature" not "Added feature"
      - Use 'git commit --amend' only when explicitly requested
      - Never 'git push --force' unless explicitly requested
    '';
  };
}
