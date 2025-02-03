{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
  ];

  home.file.".default-npm-packages".source = ./files/.default-npm-packages;
  home.file.".config/mise/config.toml".source = ./files/mise-config.toml;

  programs.zsh.initExtra = "
    eval \"$(/etc/profiles/per-user/patwoz/bin/mise activate zsh)\"
  ";

}

