{ inputs, pkgs, ... }: 

{
  # home.packages = with pkgs; [
  #   neovim
  # ];

  # environment.systemPackages = [
  #   inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  # ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
