{ ... }: {

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Berlin";
  environment.variables.LANG = "en_US.UTF-8";
  environment.variables.LC_COLLATE = "en_US.UTF-8";
  environment.variables.LC_CTYPE = "en_US.UTF-8";
  environment.variables.LC_MESSAGES = "en_US.UTF-8";
  environment.variables.LC_MONETARY = "en_US.UTF-8";
  environment.variables.LC_NUMERIC = "de_DE.UTF-8";
  environment.variables.LC_TIME = "de_DE.UTF-8";
  environment.variables.LC_ALL = "en_US.UTF-8";

  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;
}
