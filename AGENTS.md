# AGENTS.md

Guidelines for AI coding agents operating in this NixOS configuration repository.

## Repository Overview

Personal NixOS/nix-darwin configurations for Linux and macOS machines.
Pure configuration repo — no custom NixOS module options are defined.

Architecture:
- `flake.nix` — Flake definition with all inputs, outputs, and helper functions
- `hosts/<name>/` — Per-machine config (`default.nix` for system, `home.nix` for home-manager)
- `modules/` — Shared system modules (`darwin/` for macOS-specific, `system.nix` for shared)
- `home/` — Home-manager modules, each named by tool/concern (e.g., `git.nix`, `shell.nix`)
- `home/files/` — Static dotfiles sourced via `home.file.<name>.source`
- `home/nvim/` — Neovim config (LazyVim-based, Lua)

Target platforms: `aarch64-darwin` (primary), `aarch64-linux`, `x86_64-linux`.

## Build / Lint / Check Commands

All commands are in the `Makefile`. Run `make` (or `make help`) to list them.

```sh
make setup      # Install git hooks (run once after clone)
make fmt        # Format all .nix files (nixfmt-rfc-style)
make lint       # Lint .nix files with statix
make check      # Format check + flake check (same as CI)
make audit      # Scan entire repo for secrets with gitleaks
make update     # Update all flake inputs (flake.lock)
make preview    # Build config and show package diff (no apply)
make switch     # Build and apply system configuration
```

### CI Pipeline

Defined in `.github/workflows/check.yml`, runs on push to `main` and PRs:
1. **eval** — Evaluates all configurations + checks formatting (`nix fmt -- --check .`)
2. **secrets** — Runs `gitleaks` on full git history

### Verifying Changes

After any `.nix` file change:
1. `make fmt` — Format first
2. `make lint` — Check for common issues
3. `make check` — Validate the flake evaluates correctly
4. `make preview` — Review package changes before applying
5. `make switch` — Apply (only when explicitly requested by user)

There are no unit tests. Validation is via `nix flake check` and `nix fmt --check`.

## Code Style

### Formatter

`nixfmt-rfc-style` is the sole formatter, enforced via `nix fmt` and CI.
No `.editorconfig` or `treefmt.nix` exists — always use `nix fmt`.

### Nix Conventions

**Indentation:** 2 spaces. No tabs.

**Module arguments:**
- Use `{ ... }:` when no specific arguments are needed
- List named args one-per-line when there are 2+, with `...` on its own line:
  ```nix
  {
    pkgs,
    lib,
    ...
  }:
  ```

**Imports:**
- Use relative paths: `../../modules/system.nix`, `./clock.nix`
- Never use `builtins.path` or absolute paths
- Host `default.nix` imports system modules; host `home.nix` imports selectively from `../../home/`

**Attribute sets:** One attribute per line, semicolons at end.

**Lists:** One item per line when >2 items.

**Strings:**
- `"${...}"` for interpolation in single-line strings
- `'' ... ''` for multi-line strings (indented nix strings)
- No unnecessary string interpolation — use bare references when possible

**Comments:** `#` with a space after (`# This is a comment`).

**Blank lines:** Between logical sections within a module.

**Platform conditionals:**
```nix
# For list items:
pkgs.lib.optionals pkgs.stdenv.isDarwin [ ... ]
pkgs.lib.optionals pkgs.stdenv.isLinux [ ... ]

# For single values:
if pkgs.stdenv.isDarwin then ... else ...
```

**home.file patterns:**
- `.source = ./files/...` for static files
- `.text = '' ... ''` for inline content
- `force = true` when files may already exist from other tools

### Naming Conventions

- **Hosts:** Named by machine (`mbpromax`, `mmm1`, `nixos`, `orbubu`)
- **Modules:** Named by concern (`keyboard.nix`, `dock.nix`, `power.nix`)
- **Home modules:** Named by tool (`git.nix`, `shell.nix`, `nvim.nix`, `zen.nix`)
- **User:** Always `patwoz`
- **stateVersion:** `"24.11"` across all hosts — do not change without explicit instruction

### Lua (Neovim Config)

- Formatted with `stylua` (indent: 2 spaces, column width: 120)
- Config in `home/nvim/lua/` following LazyVim conventions
- Plugin specs in `lua/plugins/`, one file per plugin or concern

### Shell Scripts

- Git hooks: `#!/usr/bin/env bash`
- Backup scripts: `#!/bin/bash` with `set -e` and `trap '...' ERR`
- Inline scripts in nix: use `set -euo pipefail`
- Prefer full paths to binaries in scripts managed by nix

## Security

### Secrets

- **Never** read, commit, or suggest reading: `.env` files, `~/.ssh/*`, `~/.aws/credentials`, `secrets.nix`, `*.secret`, `*.key`, `*.pem`, `*.p12`
- If you see API keys or secrets in code, warn immediately
- Pre-commit hook scans staged changes with `gitleaks`
- Custom gitleaks rules in `.gitleaks.toml` for: Healthchecks.io UUIDs, Tailscale auth keys, age private keys
- CI also runs gitleaks on full history
- To scan the whole repo manually: `make audit`

### False Positives

Override pre-commit with `git commit --no-verify` or add allowlist entry to `.gitleaks.toml`.

## Git Workflow

- Write commit messages in **present tense imperative**: "Add feature" not "Added feature"
- Use `git commit --amend` **only** when explicitly requested
- Never `git push --force` unless explicitly requested
- Run `make setup` after cloning to install the pre-commit hook

## Key Principles

1. **Declarative over imperative** — All config belongs in `.nix` files, not manual shell commands
2. **Packages via nixpkgs** — Use nixpkgs package names, not `npm install` or `pip install`
3. **macOS Homebrew via homebrew.nix** — Declare casks and brews in `modules/darwin/brew.nix`; never run `brew install`/`brew uninstall` manually
4. **Compositional** — Hosts pick which home modules to import; not all hosts get everything
5. **Single nixpkgs pin** — All flake inputs follow the root `nixpkgs` to avoid version conflicts
6. **Format before commit** — Always run `make fmt` before committing `.nix` changes
