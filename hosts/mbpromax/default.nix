{ ... }:

{
  # imports =
  #   [
  #     ../../modules/system.nix
  #     ../../modules/packages.nix
  #   ];
  #
  # # system.configurationRevision = self.rev or self.dirtyRev or null;
  #
  # # programs.zsh.shellAliases.update = "sudo nixos-rebuild switch --flake ~/.config/nixos\\#mbpromax";
  #
  # networking.hostName = "mbpromax";
  # system.stateVersion = 5;
  # # system.stateVersion = "24.11";

  users.users.patwoz = {
    home = "/Users/patwoz";
  };

  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  home-manager = {
    users.patwoz = {
      imports = [./home.nix];
      home = {
        stateVersion = "24.11";
      };
    };
  };

  system.stateVersion = 5;
}

