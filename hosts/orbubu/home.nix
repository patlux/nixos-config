{ ... }:

{
  imports =
    [
      ../../home/core.nix
      ../../home/git.nix
      ../../home/gnupg.nix
      ../../home/mise.nix
      ../../home/nvim.nix
      ../../home/packages.nix
      ../../home/ruby.nix
      ../../home/shell.nix
    ];

  home.username = "patwoz";
  home.homeDirectory = "/home/patwoz";
  home.stateVersion = "24.11";
}
