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
      TARGET_RES="2560x1440"
      TARGET_HZ="240"
      LEFT_ORIGIN="(0,0)"
      RIGHT_ORIGIN="(2560,0)"
      LOCK_DIR="/tmp/de.patwoz.restore-oled-layout.lock"

      if [[ ! -x "$DISPLAYPLACER" ]]; then
        exit 0
      fi

      if ! mkdir "$LOCK_DIR" 2>/dev/null; then
        exit 0
      fi

      trap 'rmdir "$LOCK_DIR"' EXIT

      serial_block() {
        local serial="$1"
        local current="$2"

        awk -v serial="$serial" '
          /^Persistent screen id:/ {
            if (inblock) {
              exit
            }
          }
          $0 == "Serial screen id: " serial {
            inblock = 1
          }
          inblock {
            print
          }
        ' <<<"$current"
      }

      has_both_oleds() {
        local current
        current="$($DISPLAYPLACER list 2>/dev/null || true)"

        [[ "$current" == *"Serial screen id: $LEFT_OLED"* ]] && [[ "$current" == *"Serial screen id: $RIGHT_OLED"* ]]
      }

      has_target_layout() {
        local current left right

        current="$($DISPLAYPLACER list 2>/dev/null || true)"
        left="$(serial_block "$LEFT_OLED" "$current")"
        right="$(serial_block "$RIGHT_OLED" "$current")"

        [[ -n "$left" ]] || return 1
        [[ -n "$right" ]] || return 1
        [[ "$left" == *"Resolution: $TARGET_RES"* ]] || return 1
        [[ "$left" == *"Hertz: $TARGET_HZ"* ]] || return 1
        [[ "$left" == *"Origin: $LEFT_ORIGIN"* ]] || return 1
        [[ "$right" == *"Resolution: $TARGET_RES"* ]] || return 1
        [[ "$right" == *"Hertz: $TARGET_HZ"* ]] || return 1
        [[ "$right" == *"Origin: $RIGHT_ORIGIN"* ]] || return 1
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

      if has_target_layout; then
        exit 0
      fi

      for _ in 1 2 3 4 5 6; do
        "$DISPLAYPLACER" \
          "id:$LEFT_OLED res:$TARGET_RES hz:$TARGET_HZ color_depth:8 enabled:true scaling:on origin:$LEFT_ORIGIN degree:0" \
          "id:$RIGHT_OLED res:$TARGET_RES hz:$TARGET_HZ color_depth:8 enabled:true scaling:on origin:$RIGHT_ORIGIN degree:0" \
          || true

        if has_target_layout; then
          exit 0
        fi

        sleep 2
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

  launchd.agents.displayhotplug = {
    enable = true;
    config = {
      Label = "de.patwoz.display-hotplug-restore";
      ProgramArguments = [
        "/Users/patwoz/.local/bin/restore-oled-layout"
      ];
      RunAtLoad = true;
      WatchPaths = [
        "/Library/Preferences/com.apple.windowserver.displays.plist"
        "/Users/patwoz/Library/Preferences/ByHost"
      ];
      StandardErrorPath = "/tmp/de.patwoz.display-hotplug.err";
      StandardOutPath = "/tmp/de.patwoz.display-hotplug.out";
    };
  };
}
