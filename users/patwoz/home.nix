{ pkgs, ... }:

{
  home.username = "patwoz";
  home.homeDirectory = "/home/patwoz";

  imports =
    [
      ../../home/git.nix
      ../../home/packages.nix
      ../../home/shell.nix
    ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}

