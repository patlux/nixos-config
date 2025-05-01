{ ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/darwin
    ];

  networking.hostName = "mmm1";
  networking.computerName = "mmm1";
  system.defaults.smb.NetBIOSName = "mmm1";

  time.timeZone = "Europe/Berlin";

  users.users.patwoz = {
    home = "/Users/patwoz";
  };

  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.patwoz = {
      imports = [./home.nix];
      home = {
        homeDirectory = "/Users/patwoz";
        stateVersion = "24.11";
      };
    };
  };

  system.stateVersion = 5;
}

