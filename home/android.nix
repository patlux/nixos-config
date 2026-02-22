{ lib, ... }:

{
  programs.zsh.initContent = ''
    export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export ANDROID_AVD_HOME=$HOME/.android/avd
    # export ANDROID_AVD_HOME=/Volumes/home/VMS/Android-Emulator
    export PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH
    export PATH=$ANDROID_SDK_ROOT/emulator:$PATH
    # \"Android SDK Command-line Tools (latest)\" needs to be installed (See SETUP_MACOS.md)
    export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH

    if [ -d "$ANDROID_SDK_ROOT/emulator/emulator" ]; then
      echo "Warning: $ANDROID_SDK_ROOT/emulator/emulator resolves to a directory." >&2
      echo "MiniSim expects an executable at that path." >&2
    fi
  '';

  home.file.".local/share/minisim-android-home/emulator/emulator" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      real_sdk="$HOME/Library/Android/sdk"
      adb="$real_sdk/platform-tools/adb"

      export ANDROID_HOME="$real_sdk"
      export ANDROID_SDK_ROOT="$real_sdk"
      export ANDROID_AVD_HOME="$HOME/.android/avd"

      avd_name=""
      for arg in "$@"; do
        if [[ "$arg" == @* ]]; then
          avd_name="''${arg#@}"
          break
        fi
      done

      if [[ -n "$avd_name" ]] && [[ -x "$adb" ]]; then
        while IFS= read -r line; do
          if [[ -z "$line" ]] || [[ "$line" == "List of devices attached"* ]]; then
            continue
          fi

          device_id="''${line%%[[:space:]]*}"
          if [[ "$device_id" != emulator-* ]]; then
            continue
          fi

          current_avd="$($adb -s "$device_id" emu avd name 2>/dev/null || true)"
          current_avd="''${current_avd//$'\r'/}"
          current_avd="''${current_avd//$'\n'/}"

          if [[ "$current_avd" == "$avd_name" ]]; then
            exit 0
          fi
        done < <("$adb" devices 2>/dev/null)
      fi

      exec "$real_sdk/emulator/emulator" "$@"
    '';
  };

  home.file.".local/share/minisim-android-home/platform-tools/adb" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      exec "$HOME/Library/Android/sdk/platform-tools/adb" "$@"
    '';
  };

  home.file.".local/share/minisim-android-home/cmdline-tools/latest/bin/avdmanager" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      exec "$HOME/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager" "$@"
    '';
  };

  home.activation.minisimAndroidHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults write com.oskarkwasniewski.MiniSim androidHome -string "$HOME/.local/share/minisim-android-home"
  '';
}
