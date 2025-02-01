{ config, pkgs, ... }:

{

  users.users.patwoz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
      neovim
      git
    ];
  };

}
