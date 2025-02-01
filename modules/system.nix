{ ... }: {

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables.EDITOR = "nvim";
  services.openssh.enable = true;

}
