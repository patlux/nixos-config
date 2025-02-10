{ pkgs, ... }:


{
  imports = [
    ../../home/android.nix
    ../../home/core.nix
    ../../home/git.nix
    ../../home/gnupg.nix
    ../../home/mise.nix
    ../../home/nvim.nix
    ../../home/packages.nix
    ../../home/ruby.nix
    ../../home/shell.nix
    ../../home/wezterm.nix
    ../../modules/darwin/backup
    ../../modules/darwin/backup/cronjob.nix
  ];

  programs.zsh.shellAliases.update = "darwin-rebuild switch --flake ~/.config/nixos\\#mbpromax";

  programs.zsh.initExtra = ''
    ssh-add --apple-load-keychain 2> /dev/null
  '';

  home.packages = with pkgs; [
    pixman
    cairo
    pango
    dive
    scrcpy
    apktool
  ];

}
