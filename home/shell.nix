{ config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    defaultKeymap = "viins";

    historySubstringSearch.enable = true;
    autosuggestion.enable = true;

    shellAliases = {
      mkdir = "mkdir -p -v";
      ls = "eza";
      ll = "eza -l";
      k = "kubectl";
      grep = "grep --color=auto";
      android-talkback-enable = "adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService";
      android-talkback-disable = "adb shell settings put secure enabled_accessibility_services com.android.talkback/com.google.android.marvin.talkback.TalkBackService";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = ''
      # Directory stack (replaces prezto directory module)
      setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

      GPG_TTY="$(tty)"
      export GPG_TTY

      if [ -f ~/.zshrc_secret ]; then
        source ~/.zshrc_secret
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      format = "$directory$git_branch$git_status$character";
      right_format = "$cmd_duration$all";

      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
        vimcmd_symbol = "[<](bold blue)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style = "bold purple";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold red";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
        style = "bold yellow";
      };

      # Show language versions only when relevant files are present (starship default)
      # Keep these minimal in the right prompt
      nodejs.format = "[$symbol$version]($style) ";
      rust.format = "[$symbol$version]($style) ";
      golang.format = "[$symbol$version]($style) ";
      python.format = "[$symbol$version]($style) ";
      java.format = "[$symbol$version]($style) ";
      zig.format = "[$symbol$version]($style) ";
      kubernetes.disabled = false;
    };
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
