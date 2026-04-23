{ ... }:

{
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    TrackpadThreeFingerDrag = false;
    TrackpadThreeFingerHorizSwipeGesture = 2;
    TrackpadThreeFingerVertSwipeGesture = 2;
    TrackpadFourFingerHorizSwipeGesture = 2;
    TrackpadFourFingerVertSwipeGesture = 2;
    Dragging = true;
  };

  system.defaults.NSGlobalDomain = {
    NSWindowShouldDragOnGesture = false;
    ApplePressAndHoldEnabled = true;
    "com.apple.trackpad.scaling" = 3.0;
  };

}
