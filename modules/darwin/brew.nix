{ ... }: 

{
  homebrew.enable = true;
  homebrew.brews = [
    "pkg-config"
    "ios-deploy"
    "mattisg/mattisg/adblock"
  ];
  homebrew.casks = [
    "wezterm"
    "xcodesorg/made/xcodes"
    #  TODO: replace in home.nix as package
    "font-meslo-lg-nerd-font"
    "betterdisplay"
    "bitwarden"
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
    "duplicacy-cli"
    "gimp"
    "discord"
    "imageoptim"
    "insomnium"
    "cleanshot"
    "pixelsnap"
    "appcleaner"
    "gpg-suite"
    "minisim"
  ];
}
