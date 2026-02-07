{ ... }:

{

  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowDate = 0;
    ShowDayOfMonth = true;
    ShowSeconds = false; # Avoid per-second menu bar redraws (saves energy)
  };

}
