{ ... }: 

{
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    TrackpadThreeFingerDrag = false;
    Dragging = true;
  };

  system.defaults.NSGlobalDomain = {
    NSWindowShouldDragOnGesture = true;
    ApplePressAndHoldEnabled = true;
    "com.apple.trackpad.scaling" = 3.0;
  };

}
