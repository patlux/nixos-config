{ config, ... }:

let
  opencodeNpmCacheDir = "${config.home.homeDirectory}/.local/share/opencode/npm-cache";
  fffMcpBin = "/etc/profiles/per-user/${config.home.username}/bin/fff-mcp";
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";

    permission = {
      external_directory = {
        "*" = "ask";
        "~/dev/*" = "allow";
        "~/.agent-browser" = "allow";
        "~/.agent-browser/**" = "allow";
        "~/.config/opencode/*" = "allow";
        "~/.local/share/opencode/*" = "allow";
        "~/Library/Logs/*" = "allow";
        "/var/folders/*" = "allow";
        "/var/folders/**" = "allow";
        "/tmp/*" = "allow";
        "/private/var/folders/*" = "allow";
        "/private/var/folders/**" = "allow";
        "/private/tmp/*" = "allow";
      };

      read = {
        "*" = "allow";
        "/var/folders/*" = "allow";
        "/var/folders/**" = "allow";
        "/private/var/folders/*" = "allow";
        "/private/var/folders/**" = "allow";
        "/private/tmp/*" = "allow";

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

    mcp = {
      chrome-devtools = {
        type = "local";
        command = [
          "npx"
          "-y"
          "--registry"
          "https://registry.npmjs.org"
          "chrome-devtools-mcp@latest"
          "--autoConnect"
        ];
        environment = {
          npm_config_cache = "${opencodeNpmCacheDir}/chrome-devtools";
        };
      };
      fff = {
        type = "local";
        command = [ fffMcpBin ];
      };
    };

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

      lmstudio = {
        npm = "@ai-sdk/openai-compatible";
        name = "LM Studio (local)";
        options = {
          baseURL = "http://127.0.0.1:1234/v1";
        };
        models = {
          "qwen/qwen3.5-35b-a3b" = { };
          "qwen2.5-32b-instruct" = { };
          "text-embedding-nomic-embed-text-v1.5" = { };
          "mistralai/devstral-small-2-2512" = { };
          "qwen/qwen3-coder-30b" = { };
          "google/gemma-3-12b" = { };
          "qwen/qwen2.5-coder-32b" = { };
          "openai/gpt-oss-20b" = { };
          "olmocr-7b-0225-preview@bf16" = { };
          "olmocr-7b-0225-preview@4bit" = { };
        };
      };
    };
  };
in
{
  home.sessionVariables = {
    npm_config_cache = opencodeNpmCacheDir;
  };

  xdg.configFile = {
    "opencode/opencode.json" = {
      force = true;
      text = builtins.toJSON opencodeConfig;
    };

    # Global custom slash command: /init-nx
    "opencode/commands/init-nx.md" = {
      force = true;
      text = ''
        ---
        description: Initialize Nix setup (flake or .nix)
        agent: build
        ---

        Initialize Nix project scaffolding in the current folder.

        Parameter:
        - `$1` selects layout:
          - `flake` (default when omitted): create a root `flake.nix`
          - `.nix`: create a `.nix/`-based layout

        Requirements:
        1. Detect the project stack from files in the current folder (`package.json`, `pyproject.toml`, `go.mod`, etc.).
        2. Add all dependencies required to build/start the project from this folder via Nix.
        3. Create `.envrc` configured for the generated setup.
        4. Ensure `.gitignore` contains `.direnv`.
        5. Keep changes minimal and avoid unrelated edits.
        6. Report the files created/changed and any follow-up commands.

        If `$1` is provided and is not `flake` or `.nix`, ask which layout to use.
      '';
    };

    # Global skill: Karpathy-inspired coding behavior guidelines
    "opencode/skills/karpathy-guidelines/SKILL.md" = {
      force = true;
      text = ''
        ---
        name: karpathy-guidelines
        description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
        license: MIT
        ---

        # Karpathy Guidelines

        Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

        **Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

        ## 1. Think Before Coding

        **Don't assume. Don't hide confusion. Surface tradeoffs.**

        Before implementing:
        - State your assumptions explicitly. If uncertain, ask.
        - If multiple interpretations exist, present them - don't pick silently.
        - If a simpler approach exists, say so. Push back when warranted.
        - If something is unclear, stop. Name what's confusing. Ask.

        ## 2. Simplicity First

        **Minimum code that solves the problem. Nothing speculative.**

        - No features beyond what was asked.
        - No abstractions for single-use code.
        - No "flexibility" or "configurability" that wasn't requested.
        - No error handling for impossible scenarios.
        - If you write 200 lines and it could be 50, rewrite it.

        Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

        ## 3. Surgical Changes

        **Touch only what you must. Clean up only your own mess.**

        When editing existing code:
        - Don't "improve" adjacent code, comments, or formatting.
        - Don't refactor things that aren't broken.
        - Match existing style, even if you'd do it differently.
        - If you notice unrelated dead code, mention it - don't delete it.

        When your changes create orphans:
        - Remove imports/variables/functions that YOUR changes made unused.
        - Don't remove pre-existing dead code unless asked.

        The test: Every changed line should trace directly to the user's request.

        ## 4. Goal-Driven Execution

        **Define success criteria. Loop until verified.**

        Transform tasks into verifiable goals:
        - "Add validation" -> "Write tests for invalid inputs, then make them pass"
        - "Fix the bug" -> "Write a test that reproduces it, then make it pass"
        - "Refactor X" -> "Ensure tests pass before and after"

        For multi-step tasks, state a brief plan:
        ```
        1. [Step] -> verify: [check]
        2. [Step] -> verify: [check]
        3. [Step] -> verify: [check]
        ```

        Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
      '';
    };
  };
}
