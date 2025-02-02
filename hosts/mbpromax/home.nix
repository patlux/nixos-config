{ pkgs, ... }:


{
  imports = [
    ../../home/core.nix
    ../../home/git.nix
    ../../home/gnupg.nix
    ../../home/mise.nix
    ../../home/nvim.nix
    ../../home/packages.nix
    ../../home/ruby.nix
    ../../home/shell.nix
    ../../modules/darwin/backup
    ../../modules/darwin/backup/cronjob.nix
    ../../modules/darwin/home/keyboard.nix
  ];

  programs.zsh.shellAliases.update = "darwin-rebuild switch --flake ~/.config/nixos\\#mbpromax";

  home.packages = with pkgs; [
    pixman
    cairo
    pango
    dive
    scrcpy
    apktool
  ];

}
