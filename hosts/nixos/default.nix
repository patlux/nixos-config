{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system.nix
    ];

  users.users.patwoz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.patwoz = {
      imports = [./home.nix];
      home = {
        homeDirectory = "/home/patwoz";
        stateVersion = "24.11";
      };
    };
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.11";
}

