{ ... }: 

{
  homebrew.enable = true;
  homebrew.taps = [
    "mattisg/mattisg" # adblock
    "xcodesorg/made" # xcodes
  ];
  homebrew.brews = [
    "pkg-config"
    "ios-deploy"
    "adblock"
  ];
  homebrew.casks = [
    "wezterm"
    "xcodes"
    #  TODO: replace in home.nix as package
    "font-meslo-lg-nerd-font"
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
    "discord"
    "imageoptim"
    "insomnium"
    "cleanshot"
    "pixelsnap"
    "appcleaner"
    "gpg-suite"
    "minisim"
    "virtualbuddy"
    "timing"
  ];
  homebrew.masApps = {
    "AdGuard for Safari" = 1440147259;
    "Amphetamine" = 937984704;
    "Apple Configurator" = 1037126344;
    "Bitwarden" = 1352778147;
    "Microsoft Remote Desktop" = 1295203466;
    "Quick Camera" = 598853070;
    "Steam Link" = 1246969117;
    "Tailscale" = 1475387142;
    "TestFlight" = 899247664;
    "WireGuard" = 1451685025;
  };

  system.activationScripts.postUserActivation = {
      enable = true;
      text = ''
        echo "Enable Adblock"
        sudo /opt/homebrew/bin/adblock on
      '';
  };
}
