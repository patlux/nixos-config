{ ... }:

{
  homebrew.enable = true;
  homebrew.onActivation = {
    cleanup = "uninstall"; # Remove unlisted formulae/casks but preserve app data
    autoUpdate = true; # Run brew update before installing
    upgrade = true; # Upgrade outdated formulae/casks on activation
  };
  homebrew.taps = [
    "mattisg/mattisg" # adblock
    "xcodesorg/made" # xcodes
  ];
  homebrew.brews = [
    "pkg-config"
    "ios-deploy"
    "xcodegen"
    "mattisg/mattisg/adblock"
    "bash" # dependency of adblock — listed explicitly to prevent cleanup errors
    "hurl"
    "libyaml" # ruby-build dependency (psych extension)
    "gmp" # ruby-build dependency (bignum/openssl)
    "defaultbrowser"
  ];
  homebrew.casks = [
    "wezterm"
    "xcodes-app"
    "betterdisplay"
    "raycast"
    "arc"
    "utm"
    "viscosity"
    "vlc"
    "orbstack"
    "keepassxc"
    "joplin"
    "battery"
    "android-studio"
    "virtualbuddy"
    "timing"
    "ghostty"
    "libreoffice"
    "gimp"
    "vesktop"
    "imageoptim"
    "insomnium"
    "cleanshot"
    "pixelsnap"
    "appcleaner"
    "gpg-suite"
    "minisim"
    "rustdesk"
    "proxyman"
    "zen"
    "tableplus"
    "microsoft-teams"
    "lm-studio"
    "keyboardcleantool"
    "google-chrome"
    "session-manager-plugin"
  ];
  # homebrew.masApps = {
  #   "AdGuard for Safari" = 1440147259;
  #   "Amphetamine" = 937984704;
  #   "Apple Configurator" = 1037126344;
  #   "Bitwarden" = 1352778147;
  #   "Microsoft Remote Desktop" = 1295203266;
  #   "Quick Camera" = 598853070;
  #   "Steam Link" = 1246969117;
  #   "Tailscale" = 1475387142;
  #   "TestFlight" = 899247664;
  #   "WireGuard" = 1451685025;
  # };

  system.activationScripts.activateSettings.text = ''
    echo "Enable Adblock"
    sudo /opt/homebrew/bin/adblock on
  '';
}
