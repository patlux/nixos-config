{ ... }:

let
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";

    permission = {
      external_directory = {
        "*" = "ask";
        "~/dev/*" = "allow";
        "~/.config/opencode/*" = "allow";
        "~/Library/Logs/*" = "allow";
        "/tmp/*" = "allow";
        "/private/tmp/*" = "allow";
      };

      read = {
        "*" = "allow";
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

      patwoz owns this. Start: say hi + 1 motivating line.
      Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

      ## Language-Specific
      - If project has `tsconfig.json` or `.ts/.tsx` files, read `~/.config/opencode/TYPESCRIPT.md` before TypeScript edits

      ## Security & Privacy
      - NEVER read or suggest reading: .env files, ~/.ssh/*, ~/.aws/credentials, secret files
      - When working with configs, assume .env.example is the template, never the real .env
      - Don't commit secrets - if you see API keys in code, warn immediately

      ## Nix/NixOS Specific
      - Prefer declarative configuration in .nix files over imperative changes
      - When machine setup needs to change, update it declaratively in ~/.config/nixos instead of one-off manual commands
      - When suggesting packages: use nixpkgs names, not just 'npm install'
      - For macOS (darwin): use homebrew.nix for casks, not 'brew install'
      - Test with 'darwin-rebuild switch' or 'nixos-rebuild switch' after changes

      ## CI Recovery
      - Use the project's default CI provider and workflow tooling (GitHub, GitLab, or other)
      - If CI is red: inspect latest failed run/pipeline, reproduce locally when possible, fix, re-run/retry, repeat until green
      - Prefer the provider's native CLI/API for that project (e.g., `gh`, `glab`) or repo-documented commands
      - If CI access is blocked, report what is missing and give exact manual verification steps

      ## General Code Style
      - Keep files under ~500 lines; split or refactor when they get too large
      - For bug fixes, add a regression test when it fits the project's test strategy
      - When bringing in an upstream file, stage it in `/tmp` first, then cherry-pick; never overwrite tracked files directly

      ## Git Workflow
      - When branch name contains a ticket key (for example `ABCD-1234`), prefix commit messages as `ABCD-1234: <imperative summary>`
      - Derive the ticket key from the current branch name using the project's key format (usually `[A-Z]+-[0-9]+`)
      - Write commit messages in present tense: "Add feature" not "Added feature"
      - Use 'git commit --amend' only when explicitly requested
      - Never 'git push --force' unless explicitly requested
    '';
  };

  # Global TypeScript guidance loaded by AGENTS.md when in TS projects
  xdg.configFile."opencode/TYPESCRIPT.md" = {
    force = true;
    text = ''
      # TypeScript Rules

      - Never use `any`
      - Avoid `as ...` casts; use type guards, narrowing, unions, or constrained generics
      - Never use double assertions like `as unknown as T`
      - `as const` is allowed for literal inference
      - Use `unknown` for uncertain input, then narrow before use
    '';
  };

  # Global custom slash command: /init-nx
  xdg.configFile."opencode/commands/init-nx.md" = {
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
  xdg.configFile."opencode/skills/karpathy-guidelines/SKILL.md" = {
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
}
