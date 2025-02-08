{ nixpkgs-unstable, pkgs, ... }: 

{
  # home.packages = with nixpkgs-unstable; [
  home.packages = with pkgs; [
    neovim
  ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
