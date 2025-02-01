{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/packages.nix
    ];

  programs.zsh.shellAliases.update = "sudo nixos-rebuild switch --flake ~/.config/nixos\\#nixos";

  users.users.patwoz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  home-manager = {
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

