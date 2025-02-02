{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
  ];

  programs.zsh.initExtra = "
    eval \"$(/etc/profiles/per-user/patwoz/bin/mise activate zsh)\"
  ";

}

