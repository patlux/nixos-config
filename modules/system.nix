{ ... }: {

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Berlin";
  # i18n.defaultLocale = "en_US.UTF-8";
  environment.variables.LC_ALL = "en_US.UTF-8";

  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;
}
