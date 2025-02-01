{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
  ];

  programs.zsh.initExtra = "
    eval \"$(~/.nix-profile/bin/mise activate zsh)\"
  ";

}

