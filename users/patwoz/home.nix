{ pkgs, ... }:

{
  imports =
    [
      ../../home/core.nix
      ../../home/git.nix
      ../../home/packages.nix
      ../../home/shell.nix
    ];
}

