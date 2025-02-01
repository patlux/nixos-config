{ pkgs, ... }:

{
  # users.users.patwoz = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ];
  # };
  programs.zsh.enable = true;
  # users.defaultUserShell = pkgs.zsh;
}
