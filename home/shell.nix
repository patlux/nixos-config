{ config, ... }:

{
  programs.zsh = {
    enable = true;

    shellAliases = {
      mkdir = "mkdir -p -v";
      ls = "eza";
      ll = "eza -l";
      k = "kubectl";
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
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.bin"
    "${config.home.homeDirectory}/.bin/bin"
    "${config.home.homeDirectory}/.bun/bin"
    # TODO: only for mac
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
}


