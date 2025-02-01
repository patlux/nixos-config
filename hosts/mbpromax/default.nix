{ ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/packages.nix
      ../../modules/darwin
    ];
  #
  # # system.configurationRevision = self.rev or self.dirtyRev or null;
  #

  networking.hostName = "mbpromax";
  networking.computerName = "mbpromax";
  system.defaults.smb.NetBIOSName = "mbpromax";

  time.timeZone = "Europe/Berlin";

  users.users.patwoz = {
    home = "/Users/patwoz";
  };

  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  home-manager = {
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

