{ ... }:

{
    
  system.defaults.finder = {
    FXEnableExtensionChangeWarning = false;
    _FXShowPosixPathInTitle = true; # show full path in finder title
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    ShowPathbar = true;
    ShowStatusBar = true;
    QuitMenuItem = true;
    FXPreferredViewStyle = "Nlsv"; # List (https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.finder.FXPreferredViewStyle)
    CreateDesktop = false;
  };

}
