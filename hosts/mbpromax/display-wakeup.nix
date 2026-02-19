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
      FALLBACK_HZ="120"
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

      select_mode() {
        local block="$1"

        if [[ "$block" == *"res:$TARGET_RES hz:$TARGET_HZ color_depth:8 scaling:on"* ]]; then
          echo "res:$TARGET_RES hz:$TARGET_HZ color_depth:8 scaling:on"
          return 0
        fi

        if [[ "$block" == *"res:$TARGET_RES hz:$TARGET_HZ color_depth:8"* ]]; then
          echo "res:$TARGET_RES hz:$TARGET_HZ color_depth:8"
          return 0
        fi

        if [[ "$block" == *"res:$TARGET_RES hz:$FALLBACK_HZ color_depth:8 scaling:on"* ]]; then
          echo "res:$TARGET_RES hz:$FALLBACK_HZ color_depth:8 scaling:on"
          return 0
        fi

        if [[ "$block" == *"res:$TARGET_RES hz:$FALLBACK_HZ color_depth:8"* ]]; then
          echo "res:$TARGET_RES hz:$FALLBACK_HZ color_depth:8"
          return 0
        fi

        if [[ "$block" == *"res:1920x1080 hz:$TARGET_HZ color_depth:8 scaling:on"* ]]; then
          echo "res:1920x1080 hz:$TARGET_HZ color_depth:8 scaling:on"
          return 0
        fi

        if [[ "$block" == *"res:1920x1080 hz:$TARGET_HZ color_depth:8"* ]]; then
          echo "res:1920x1080 hz:$TARGET_HZ color_depth:8"
          return 0
        fi

        if [[ "$block" == *"res:1920x1080 hz:$FALLBACK_HZ color_depth:8 scaling:on"* ]]; then
          echo "res:1920x1080 hz:$FALLBACK_HZ color_depth:8 scaling:on"
          return 0
        fi

        if [[ "$block" == *"res:1920x1080 hz:$FALLBACK_HZ color_depth:8"* ]]; then
          echo "res:1920x1080 hz:$FALLBACK_HZ color_depth:8"
          return 0
        fi

        return 1
      }

      extract_origin() {
        local block="$1"

        awk '
          /^Origin:/ {
            print $2
            exit
          }
        ' <<<"$block"
      }

      mode_is_current() {
        local block="$1"
        local mode="$2"
        local current_mode

        current_mode="$(awk '/<-- current mode/ { print; exit }' <<<"$block")"
        [[ -n "$current_mode" ]] && [[ "$current_mode" == *"$mode"* ]]
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
        current="$($DISPLAYPLACER list 2>/dev/null || true)"
        left="$(serial_block "$LEFT_OLED" "$current")"
        right="$(serial_block "$RIGHT_OLED" "$current")"

        left_mode="$(select_mode "$left" || true)"
        right_mode="$(select_mode "$right" || true)"
        left_origin="$(extract_origin "$left")"
        right_origin="$(extract_origin "$right")"

        if [[ -z "$left_mode" ]] || [[ -z "$right_mode" ]] || [[ -z "$left_origin" ]] || [[ -z "$right_origin" ]]; then
          sleep 2
          continue
        fi

        if mode_is_current "$left" "$left_mode" && mode_is_current "$right" "$right_mode"; then
          exit 0
        fi

        "$DISPLAYPLACER" \
          "id:$LEFT_OLED $left_mode enabled:true origin:$left_origin degree:0" \
          "id:$RIGHT_OLED $right_mode enabled:true origin:$right_origin degree:0" \
          || true

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
