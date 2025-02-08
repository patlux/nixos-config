{ pkgs, ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/packages.nix
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

  networking.hostName = "ubuntu";
  networking.networkmanager.enable = true;

  system.stateVersion = "24.11";
}

