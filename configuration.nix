# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables.EDITOR = "nvim";

  users.users.patwoz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
      neovim
      git
    ];
  };

  programs.firefox.enable = true;
  programs.sway.enable = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    git
    vim
    wget
    wayland
    xwayland
    sway
    swaylock
    swayidle
    waybar
    wlroots
    wl-clipboard
    nodejs
    file
  ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  system.stateVersion = "24.11";
}

