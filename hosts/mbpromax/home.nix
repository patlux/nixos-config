{ pkgs, ... }:

{
  imports = [
    ../../home/android.nix
    ../../home/core.nix
    ../../home/codexbar.nix
    ../../home/direnv.nix
    ../../home/git.nix
    ../../home/gnupg.nix
    ../../home/mise.nix
    ../../home/nvim.nix
    ../../home/opencode.nix
    ../../home/packages.nix
    ../../home/ruby.nix
    ../../home/shell.nix
    ../../home/wezterm.nix
    ../../home/zen.nix
    ../../modules/darwin/backup
    ../../modules/darwin/backup/cronjob.nix
  ];

  programs.zsh.shellAliases.update = "sudo darwin-rebuild switch --flake ~/.config/nixos\\#mbpromax";

  programs.zsh.initContent = ''
    if [[ -n "$SSH_AUTH_SOCK" ]] && ! ssh-add -l >/dev/null 2>&1; then
      ssh-add --apple-load-keychain >/dev/null 2>&1 || true
    fi
  '';

  home.packages = with pkgs; [
    pixman
    cairo
    pango
    dive
    scrcpy
    apktool
  ];

  home.file.".local/bin/tailscale" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec -a Tailscale /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
    '';
  };

}
