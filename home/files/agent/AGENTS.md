# Personal Coding Standards

patwoz owns this. Start: say hi + 1 motivating line.
Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Language-Specific
- If project has `tsconfig.json` or `.ts/.tsx` files, read `__TYPESCRIPT_PATH__` before TypeScript edits

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

## Chrome MCP
- When Chrome work is requested, always use the `chrome-devtools` MCP tools
- Always attach to an already running Chrome instance; do not start or control Chrome via AppleScript or `osascript`
- Prefer an already open tab that matches the expected URL
- Only open a new tab when no existing tab matches the expected URL
- Never use AppleScript or `osascript` to control Chrome when Chrome MCP is available

## FFF MCP
- For file search or grep in the current git-indexed directory, prefer the `fff` MCP tools over built-in search tools
- Use the `fff` MCP tools for repeated search/refactor workflows before falling back to shell `rg` or `find`

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
