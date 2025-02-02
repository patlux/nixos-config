{ ... }:

{
  home.username = "patwoz";
  # home.homeDirectory = "/home/patwoz"; 

  home.file.".bin" = {
    source = ./bin;
    recursive = true;
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
