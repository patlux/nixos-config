{ ... }:

{
  home.file.".local/bin/restore-oled-layout" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      DISPLAYPLACER="/opt/homebrew/bin/displayplacer"
      LEFT_OLED="s808859987"
      RIGHT_OLED="s808669267"

      if [[ ! -x "$DISPLAYPLACER" ]]; then
        exit 0
      fi

      has_both_oleds() {
        local current
        current="$($DISPLAYPLACER list 2>/dev/null || true)"

        [[ "$current" == *"Serial screen id: $LEFT_OLED"* ]] && [[ "$current" == *"Serial screen id: $RIGHT_OLED"* ]]
      }

      for _ in 1 2 3 4 5 6 7 8 9 10; do
        if has_both_oleds; then
          break
        fi

        sleep 2
      done

      if ! has_both_oleds; then
        exit 0
      fi

      for _ in 1 2 3 4 5 6; do
        sleep 2
        "$DISPLAYPLACER" \
          "id:$LEFT_OLED res:2560x1440 hz:240 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
          "id:$RIGHT_OLED res:2560x1440 hz:240 color_depth:8 enabled:true scaling:on origin:(2560,0) degree:0" \
          && exit 0
      done

      exit 0
    '';
  };

  home.file.".sleep" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      exit 0
    '';
  };

  home.file.".wakeup" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      /Users/patwoz/.local/bin/restore-oled-layout >>/tmp/de.patwoz.display-wakeup.out 2>>/tmp/de.patwoz.display-wakeup.err
    '';
  };

  launchd.agents.sleepwatcher = {
    enable = true;
    config = {
      Label = "de.patwoz.sleepwatcher";
      ProgramArguments = [
        "/opt/homebrew/opt/sleepwatcher/sbin/sleepwatcher"
        "-V"
        "-s"
        "/Users/patwoz/.sleep"
        "-w"
        "/Users/patwoz/.wakeup"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/tmp/de.patwoz.sleepwatcher.err";
      StandardOutPath = "/tmp/de.patwoz.sleepwatcher.out";
    };
  };
}
