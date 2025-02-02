{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    ruby
  ];

  home.file.".gemrc".source = ./files/.gemrc;
  home.file.".default-gems".source = ./files/.default-gems;

  programs.zsh.initExtra = "
    if [ $(mise ls ruby | wc -l) -gt 1 ]; then
      export GEM_HOME=$(mise exec ruby --command 'ruby -e \"puts Gem.user_dir\"')
      export PATH=$PATH:$GEM_HOME/bin
    fi
  ";
}
