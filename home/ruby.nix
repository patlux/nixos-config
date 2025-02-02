{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    ruby
  ];

  home.file.".gemrc".text = ''
    gem: --user-install --env-shebang --no-document
  '';

  home.file.Gemfile.text = ''
source 'https://rubygems.org'

gem 'cocoapods'
  '';

  programs.zsh.initExtra = "
    if [ $(mise ls ruby | wc -l) -gt 1 ]; then
      export GEM_HOME=$(mise exec ruby --command 'ruby -e \"puts Gem.user_dir\"')
      export PATH=$PATH:$GEM_HOME/bin
    fi
  ";
}
