{ ... }:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    historyLimit = 100000;
    terminal = "screen-256color";

    extraConfig = ''
      set -g base-index 1
      set -g renumber-windows on
      set -g set-clipboard on
      set -g focus-events on

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
