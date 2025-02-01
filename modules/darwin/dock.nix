{...}: {

  system.defaults.dock = {
    orientation = "right";
    show-recents = false; # do not show recent apps in dock
    mru-spaces = false; # do not automatically rearrange spaces based on most recent use.
    tilesize = 36;
    launchanim = false;
    expose-animation-duration = 0.1;
    persistent-apps = [
      # Not needed, it's already included
      # "/System/Library/CoreServices/Finder.app"
      "/Applications/Arc.app"
      "/Applications/WezTerm.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Notes.app"
    ];
    # persistent-others = [
    #   "/Volumes/home"
    #   "/Volumes/GF"
    # ];
  };

}
