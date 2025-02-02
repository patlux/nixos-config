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
  ];
}
