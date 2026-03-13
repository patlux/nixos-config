{ pkgs, ... }:

{
  imports = [
    ../../home/android.nix
    ../../home/core.nix
    ../../home/direnv.nix
    ../../home/git.nix
    ../../home/ghostty.nix
    ../../home/gnupg.nix
    ../../home/mise.nix
    ../../home/nvim.nix
    ../../home/opencode.nix
    ../../home/packages.nix
    ../../home/ruby.nix
    ../../home/shell.nix
    ../../home/tmux.nix
    ../../home/wezterm.nix
  ];

  programs.zsh.shellAliases.update = "sudo darwin-rebuild switch --flake ~/.config/nixos\\#mmm1";

  programs.zsh.initContent = ''
    if [[ -n "$SSH_AUTH_SOCK" ]] && ! ssh-add -l >/dev/null 2>&1; then
      ssh-add --apple-load-keychain >/dev/null 2>&1 || true
    fi
  '';

}
