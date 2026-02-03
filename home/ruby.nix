{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    ruby
  ];

  home.file.".gemrc".source = ./files/.gemrc;
  home.file.".default-gems".source = ./files/.default-gems;

  programs.zsh.initContent = ''
    if [ $(mise ls ruby | wc -l) -ge 1 ]; then
      export PATH="$(mise exec ruby -- ruby -e 'puts Gem.user_dir')/bin:$PATH"
    fi
  '';
}
