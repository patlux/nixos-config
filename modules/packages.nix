{ pkgs, ... }: {

  # System wide installed programs

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    git
    vim
    wget
    wayland
    xwayland
    sway
    swaylock
    swayidle
    waybar
    wlroots
    wl-clipboard
    file
  ];

}
