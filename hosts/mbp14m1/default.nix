{ ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/darwin
  ];

  networking.hostName = "mbp14m1";
  networking.computerName = "mbp14m1";
  system.defaults.smb.NetBIOSName = "mbp14m1";

  time.timeZone = "Europe/Berlin";

  users.users.patwoz = {
    home = "/Users/patwoz";
  };

  system.primaryUser = "patwoz";

  programs.zsh.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.patwoz = {
      imports = [ ./home.nix ];
      home = {
        homeDirectory = "/Users/patwoz";
        stateVersion = "24.11";
      };
    };
  };

  system.stateVersion = 5;
}
