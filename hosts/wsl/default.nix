{ pkgs, ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/packages.nix
    ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.root = {
      imports = [./home.nix];
      home = {
        homeDirectory = "/root";
        stateVersion = "24.11";
      };
    };
  };

  networking.hostName = "WS964";
  networking.networkmanager.enable = true;

  system.stateVersion = "24.11";
}

