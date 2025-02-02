{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
  ];

  home.file.".default-npm-packages".source = ./files/.default-npm-packages;

  programs.zsh.initExtra = "
    eval \"$(/etc/profiles/per-user/patwoz/bin/mise activate zsh)\"
  ";

}

