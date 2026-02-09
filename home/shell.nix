{
  config,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    defaultKeymap = "viins";

    historySubstringSearch.enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      mkdir = "mkdir -p -v";
      k = "kubectl";
      lg = "lazygit";
      grep = "grep --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
      android-talkback-enable = "adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService";
      android-talkback-disable = "adb shell settings put secure enabled_accessibility_services com.android.talkback/com.google.android.marvin.talkback.TalkBackService";
    };

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    initContent = ''
      # Directory stack (replaces prezto directory module)
      setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

      secret_backend() {
        if [[ "$OSTYPE" == darwin* ]] && command -v security >/dev/null 2>&1; then
          print -r -- "macos-keychain"
          return 0
        fi

        if command -v pass >/dev/null 2>&1; then
          print -r -- "pass"
          return 0
        fi

        if command -v secret-tool >/dev/null 2>&1; then
          print -r -- "secret-tool"
          return 0
        fi

        print -r -- "none"
      }

      secret_get() {
        local name backend value
        name="$1"
        if [[ -z "$name" ]]; then
          print -u2 -- "usage: secret_get <NAME>"
          return 2
        fi

        backend="$(secret_backend)"
        case "$backend" in
          macos-keychain)
            security find-generic-password -a "$USER" -s "$name" -w
            ;;
          pass)
            value="$(pass show "env/$name" 2>/dev/null)" || return 1
            print -r -- "''${value%%$'\n'*}"
            ;;
          secret-tool)
            secret-tool lookup app shell-secrets name "$name"
            ;;
          *)
            print -u2 -- "no supported secret backend found (need macOS Keychain, pass, or secret-tool)"
            return 1
            ;;
        esac
      }

      secret_set() {
        local name backend value
        name="$1"
        if [[ -z "$name" ]]; then
          print -u2 -- "usage: secret_set <NAME>"
          return 2
        fi

        backend="$(secret_backend)"
        read -r -s "value?$name: "
        print

        case "$backend" in
          macos-keychain)
            security add-generic-password -a "$USER" -s "$name" -w "$value" -U >/dev/null
            ;;
          pass)
            printf '%s' "$value" | pass insert -m -f "env/$name" >/dev/null
            ;;
          secret-tool)
            printf '%s' "$value" | secret-tool store --label="$name" app shell-secrets name "$name" >/dev/null
            ;;
          *)
            print -u2 -- "no supported secret backend found (need macOS Keychain, pass, or secret-tool)"
            return 1
            ;;
        esac
      }

      secret_del() {
        local name backend
        name="$1"
        if [[ -z "$name" ]]; then
          print -u2 -- "usage: secret_del <NAME>"
          return 2
        fi

        backend="$(secret_backend)"
        case "$backend" in
          macos-keychain)
            security delete-generic-password -a "$USER" -s "$name" >/dev/null
            ;;
          pass)
            pass rm -f "env/$name" >/dev/null
            ;;
          secret-tool)
            secret-tool clear app shell-secrets name "$name" >/dev/null
            ;;
          *)
            print -u2 -- "no supported secret backend found (need macOS Keychain, pass, or secret-tool)"
            return 1
            ;;
        esac
      }

      withsecret() {
        local name value
        name="$1"
        shift

        if [[ -z "$name" || "$#" -eq 0 ]]; then
          print -u2 -- "usage: withsecret <NAME> <command> [args...]"
          return 2
        fi

        value="$(secret_get "$name")" || {
          print -u2 -- "failed to read secret: $name"
          return 1
        }

        env "$name=$value" "$@"
      }

      kget() { secret_get "$@"; }
      kset() { secret_set "$@"; }
      kdel() { secret_del "$@"; }

      # Fix backspace/delete in vi mode for recalled history lines
      # BACKSPACE_PAST_START lets backspace delete past insert-mode entry point
      zle -A .backward-delete-char vi-backward-delete-char
      bindkey -M viins '^?' backward-delete-char
      bindkey -M viins '^H' backward-delete-char
      bindkey -M viins '^W' backward-kill-word
      bindkey -M viins '^U' backward-kill-line

      # Tab: accept autosuggestion if visible, otherwise do normal completion
      autosuggest-accept-or-complete() {
        if [[ -n "$POSTDISPLAY" ]]; then
          zle autosuggest-accept
        else
          zle expand-or-complete
        fi
      }
      zle -N autosuggest-accept-or-complete
      bindkey -M viins '^I' autosuggest-accept-or-complete

      # Bind arrow keys to prefix-based history search (matches start of line)
      autoload -U history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey '^[[A' history-beginning-search-backward-end
      bindkey '^[[B' history-beginning-search-forward-end
      bindkey -M vicmd 'k' history-beginning-search-backward-end
      bindkey -M vicmd 'j' history-beginning-search-forward-end

      # Bind Ctrl+Arrow keys to substring history search (matches anywhere)
      bindkey '^[[1;5A' history-substring-search-up
      bindkey '^[[1;5B' history-substring-search-down

      GPG_TTY="$(tty)"
      export GPG_TTY

      if [ -f ~/.zshrc_secret ]; then
        chmod 600 ~/.zshrc_secret 2>/dev/null || true
        source ~/.zshrc_secret
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      format = "$directory$character";
      right_format = "$git_branch$cmd_duration";

      # Sonokai palette colors
      character = {
        success_symbol = "[>](bold #9ed072)";
        error_symbol = "[>](bold #fc5d7c)";
        vimcmd_symbol = "[<](bold #76cce0)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold #76cce0";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style = "bold #b39df3";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
        style = "bold #e7c664";
      };
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.bin"
    "${config.home.homeDirectory}/.bin/bin"
    "${config.home.homeDirectory}/.bun/bin"
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
}
