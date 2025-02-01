{ pkgs, ... }: {

  # System wide installed programs

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    git
    vim
    wget
    file
  ];

}
