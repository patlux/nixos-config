{ ... }: 

{
  # TODO: move all settings from set-defaults.ts to here
  system.defaults.dock = {
    autohide = false;
    orientation = "right";
    show-recents = false; # do not show recent apps in dock
    mru-spaces = false; # do not automatically rearrange spaces based on most recent use.
    tilesize = 36;
    launchanim = false;
    expose-animation-duration = 0.1;
  };

  system.defaults.finder = {
    FXEnableExtensionChangeWarning = false;
    _FXShowPosixPathInTitle = true; # show full path in finder title
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    ShowPathbar = true;
    ShowStatusBar = true;
    QuitMenuItem = true;
    FXPreferredViewStyle = "List";
    CreateDesktop = false;
  };

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    TrackpadThreeFingerDrag = false;
    Dragging = true;
  };

  system.defaults.NSGlobalDomain = {
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    InitialKeyRepeat = 12;
    KeyRepeat = 2;
    "com.apple.sound.beep.feedback" = 0;
    AppleInterfaceStyleSwitchesAutomatically = true;
    AppleEnableSwipeNavigateWithScrolls = true;
    NSAutomaticWindowAnimationsEnabled = false;
    NSTableViewDefaultSizeMode = 1;
    ApplePressAndHoldEnabled = true;
    NSWindowResizeTime = 0.001;
    AppleFontSmoothing = 2;
    NSWindowShouldDragOnGesture = true;
    "com.apple.trackpad.scaling" = 3.0;
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
    "com.assple.SoftwareUpdate" = {
      ScheduleFrequency = 1;
    };
    "com.apple.terminal" = {
      StringEncodings = 4;
    };
  };

  system.defaults.screensaver = {
    askForPassword = true;
  };

  system.defaults.loginwindow = {
    GuestEnabled = false;
    ShutDownDisabled = true;
    SleepDisabled = true;
    RestartDisabled = true;
    ShutDownDisabledWhileLoggedIn = true;
    PowerOffDisabledWhileLoggedIn = true;
    RestartDisabledWhileLoggedIn = true;
    DisableConsoleAccess = true;
  };

  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowDate = 0;
    ShowDayOfMonth = true;
    ShowSeconds = true;
  };

  system.defaults.alf = { # firewall
    globalstate = 1; # enable
  };

  system.activationScripts.postUserActivation.text = ''
    printf "disabling spotlight indexing... "
    mdutil -i off -d / &> /dev/null
    mdutil -E / &> /dev/null
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
