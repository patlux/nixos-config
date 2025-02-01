{ config, ... }:

{
  programs.zsh = {
    enable = true;

    shellAliases = {
      mkdir = "mkdir -p -v";
      aic = "aider --model r1 --no-attribute-author --no-attribute-committer";
      dgit = "git --git-dir ~/.dotfiles/.git --work-tree=$HOME";
      ls = "eza";
      ll = "eza -l";
      la = "eza -a";
      lt = "eza --tree";
      lla = "eza -la" ;
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    prezto = {
      enable = true;
      editor = { keymap = "vi"; };
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        "completion"
        "history-substring-search"
        "prompt"
        "git"
      ];
    };

    initExtra = "
      GPG_TTY=\"$(tty)\"
      export GPG_TTY

      if [ -f ~/.zshrc_secret ]; then
        source ~/.zshrc_secret
      fi
    ";
  };

  home.sessionPath = [
    # TODO: only for mac
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.bin"
    "${config.home.homeDirectory}/.bin/bin"
  ];
}


