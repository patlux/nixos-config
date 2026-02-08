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
}
