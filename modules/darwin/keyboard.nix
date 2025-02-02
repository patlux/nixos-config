{ ... }:

{
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.defaults.NSGlobalDomain = {
    AppleKeyboardUIMode = 3;
    InitialKeyRepeat = 12;
    KeyRepeat = 2;
  };
}
