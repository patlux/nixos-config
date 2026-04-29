{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../home/agents.nix
    ../../home/claude.nix
    ../../home/core.nix
    ../../home/direnv.nix
    ../../home/git.nix
    ../../home/gnupg.nix
    ../../home/mise.nix
    ../../home/nvim.nix
    ../../home/pi.nix
    ../../home/packages.nix
    ../../home/ruby.nix
    ../../home/shell.nix
    ../../home/tmux.nix
  ];

  home.username = "patwoz";
  home.homeDirectory = "/home/patwoz";
  home.stateVersion = "24.11";
}
