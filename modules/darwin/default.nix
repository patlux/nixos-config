{ ... }:

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
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.NSGlobalDomain = {
    "com.apple.sound.beep.feedback" = 0;
    AppleInterfaceStyleSwitchesAutomatically = true;
    AppleEnableSwipeNavigateWithScrolls = true;
    NSAutomaticWindowAnimationsEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSTableViewDefaultSizeMode = 1;
    NSWindowResizeTime = 0.001;
    AppleFontSmoothing = 2;
  };

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
    # "com.apple.Safari" = {
    #   Homepage = "about:blank";
    #   UniversalSearchEnabled = false;
    #   SuppressSearchSuggestions = true;
    # };
    "com.apple.NetworkBrowser" = {
      BrowseAllInterfaces = 1;
    };
    "com.apple.SoftwareUpdate" = {
      ScheduleFrequency = 1;
    };
    "com.apple.terminal" = {
      StringEncodings = 4;
    };
  };

  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.blockAllIncoming = true;
  networking.applicationFirewall.enableStealthMode = true;

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
