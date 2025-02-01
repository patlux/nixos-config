{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    ruby
  ];

  home.file.".gemrc".text = ''
    gem: --user-install --env-shebang --no-document
  '';

  programs.zsh.initExtra = "
    export GEM_HOME=$(mise exec ruby --command 'ruby -e \"puts Gem.user_dir\"')
    export PATH=$PATH:$GEM_HOME/bin
  ";
}
