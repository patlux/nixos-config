{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ruby
  ];

  home.file.".gemrc".source = ./files/.gemrc;
  home.file.".default-gems".source = ./files/.default-gems;

  programs.zsh.initContent = ''
    for gem_user_bin in $HOME/.gem/ruby/*/bin(N); do
      export PATH="$gem_user_bin:$PATH"
    done
  '';
}
