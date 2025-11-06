{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    ruby
  ];

  home.file.".gemrc".source = ./files/.gemrc;
  home.file.".default-gems".source = ./files/.default-gems;

  programs.zsh.initContent = "
    if [ $(mise ls ruby | wc -l) -ge 1 ]; then
      export GEM_HOME=$(mise exec ruby@2.7.6 --command 'ruby -e \"puts Gem.user_dir\"')
      export PATH=$PATH:$GEM_HOME/bin
    fi
  ";
}
