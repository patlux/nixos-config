{ ... }:

{
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
  
  system.keyboard.userKeyMapping = [
    # To easier enter "@"
    {
      # Right Command to Option
      HIDKeyboardModifierMappingSrc = 30064771303;
      HIDKeyboardModifierMappingDst = 30064771302;
    }
    {
      # Right Option to command
      HIDKeyboardModifierMappingSrc = 30064771302;
      HIDKeyboardModifierMappingDst = 30064771303;
    }
  ];

  system.defaults.NSGlobalDomain = {
    AppleKeyboardUIMode = 3;
    InitialKeyRepeat = 12;
    KeyRepeat = 2;
  };
}
