{ ... }:

{
  system.defaults.screensaver = {
    askForPassword = true;
    askForPasswordDelay = 0;
  };

  system.defaults.loginwindow = {
    GuestEnabled = false;
    ShutDownDisabled = true;
    SleepDisabled = true;
    RestartDisabled = true;
    ShutDownDisabledWhileLoggedIn = true;
    PowerOffDisabledWhileLoggedIn = true;
    RestartDisabledWhileLoggedIn = true;
    DisableConsoleAccess = true;
    LoginwindowText = "Servus!";
  };
}
