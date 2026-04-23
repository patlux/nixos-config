{ ... }:

let
  claudeConfig = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    model = "opus";
    enabledPlugins = {
      "playground@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
    permissions = {
      additionalDirectories = [ "~/dev" ];
      allow = [
        "Read(.)"
        "Edit(.)"
        "Write(.)"
        "Read(~/dev/**)"
        "Edit(~/dev/**)"
        "Write(~/dev/**)"
        "Bash(npx tsc:*)"
        "Bash(npx eslint:*)"
        "Bash(npx vitest:*)"
        "Bash(pnpm lint:*)"
        "Bash(pnpm typecheck:*)"
        "Bash(pnpm test:*)"
        "Bash(pnpm build:*)"
        "Bash(npx expo export:web:*)"
        "Bash(git add:*)"
        "Bash(git commit:*)"
        "Bash(git:*)"
        "Bash(bun run:*)"
        "Bash(python3:*)"
        "Bash(npx agent-browser:*)"
      ];
      deny = [
        "Read(//**)"
        "Edit(//**)"
        "Write(//**)"
      ];
    };
  };
in
{
  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON claudeConfig;
  };
}
