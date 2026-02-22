{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./clock.nix
    ./dock.nix
    ./finder.nix
    ./keyboard.nix
    ./screensaver.nix
    ./trackpad.nix

    ./skhd.nix
    ./yabai.nix

    ./brew.nix
    ./power.nix
  ];

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=60
  '';

  system.defaults.NSGlobalDomain = {
    "com.apple.sound.beep.feedback" = 0;
    AppleInterfaceStyleSwitchesAutomatically = true;
    AppleEnableSwipeNavigateWithScrolls = true;
    NSAutomaticWindowAnimationsEnabled = false;
    NSTableViewDefaultSizeMode = 1;
    NSWindowResizeTime = 0.001;
    AppleFontSmoothing = 0; # Disable subpixel smoothing (unnecessary on Retina)

    # Disable auto-correct annoyances for developers
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;

    # Expand save and print dialogs by default
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;

    # Save to disk, not iCloud, by default
    NSDocumentSaveNewDocumentsToCloud = false;

    # Force 24-hour time system-wide
    AppleICUForce24HourTime = true;

    # Click scrollbar to jump to clicked position
    AppleScrollerPagingBehavior = true;

    # Prefer tabs when opening documents
    AppleWindowTabbingMode = "always";
  };

  # Login window: require username + password (not user list)
  system.defaults.loginwindow.SHOWFULLNAME = true;

  # Independent spaces per display (better for multi-monitor + yabai)
  system.defaults.spaces.spans-displays = false;

  # Disable Stage Manager click-wallpaper-to-show-desktop
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      # Add a context menu item for showing the Web Inspector in web views
      WebKitDeveloperExtras = true;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.NetworkBrowser" = {
      BrowseAllInterfaces = 1;
    };
    "com.apple.SoftwareUpdate" = {
      ScheduleFrequency = 1;
    };
    "com.apple.terminal" = {
      StringEncodings = 4;
    };
    # Privacy: disable personalized advertising
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    # Stop "Use this disk for Time Machine?" prompts
    "com.apple.TimeMachine" = {
      DoNotOfferNewDisksForBackup = true;
    };
    # Stop Photos from opening when connecting devices
    "com.apple.ImageCapture" = {
      disableHotPlug = true;
    };
    # Screenshots: no window shadow, save as PNG
    "com.apple.screencapture" = {
      disable-shadow = true;
      type = "png";
    };
  };

  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.blockAllIncoming = false;
  networking.applicationFirewall.enableStealthMode = true;

  launchd.user.envVariables =
    let
      primaryUser = config.system.primaryUser or null;
      primaryUserHome =
        if primaryUser == null then
          null
        else
          lib.attrByPath [ "users" "users" primaryUser "home" ] "/Users/${primaryUser}" config;
      androidSdkRoot = if primaryUserHome == null then null else "${primaryUserHome}/Library/Android/sdk";
    in
    lib.mkIf (androidSdkRoot != null) {
      ANDROID_HOME = androidSdkRoot;
      ANDROID_SDK_ROOT = androidSdkRoot;
      ANDROID_AVD_HOME = "${primaryUserHome}/.android/avd";
    };

  system.activationScripts.activateSettings.text = ''
    printf "disabling spotlight indexing... "
    sudo mdutil -a -i off
    sudo mdutil -E /
    echo "ok"

    # Show the ~/Library folder.
    chflags nohidden ~/Library

    # Show hidden files and file extensions by default

    # Disable animations when opening a Quick Look window.
    defaults write -g QLPanelAnimationDuration -float 0

    # Allow text-selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    # Disables the keyboard short "Select the previous input source"
    # which makes it possible to use Control-Space (for e.g. in neovim)
    defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 60 "
      <dict>
        <key>enabled</key><false/>
        <key>value</key><dict>
          <key>type</key><string>standard</string>
          <key>parameters</key>
          <array>
            <integer>32</integer>
            <integer>49</integer>
            <integer>262144</integer>
          </array>
        </dict>
      </dict>
    "
  '';

}
