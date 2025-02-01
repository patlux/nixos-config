{ ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/packages.nix
    ];

  system.configurationRevision = self.rev or self.dirtyRev or null;

  programs.zsh.shellAliases.update = "sudo nixos-rebuild switch --flake ~/.config/nixos\\#mbpromax";

  networking.hostName = "mbpromax";
  system.stateVersion = "24.11";
}

