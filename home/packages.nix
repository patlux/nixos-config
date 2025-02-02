{ pkgs, ... }:

{

  programs.fzf.enable = true;
  programs.fzf.defaultCommand = "fd --type file --hidden --exclude .git";

  home.file.".config/mise/config.toml".source = ./files/mise-config.toml;
  home.file.".config/wezterm/wezterm.lua".source = ./files/wezterm.lua;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip # for neovim
    p7zip

    neovim
    eza # ls alternative
    pinentry-curses
    delta # better diff
    fd # better "find"
    ncdu
    watchman
    imagemagick
    ffmpeg
    rsync
    cmake
    hyperfine
    wget
    lazygit
    picocom
    uv
    bat
    duplicacy

    # for neovim
    tree-sitter
    go
    gofumpt
    gopls
    cargo

    ripgrep # recursively searches directories for a regex pattern
    jq # json parser

    dnsutils  # `dig` + `nslookup`

    file
    which
    tree
    gnused
    gnutar
    gnumake
    gawk
    zstd
    gnupg

    btop  # replacement of htop/nmon
    # not available on mac
    # iotop # io monitoring
    iftop # network monitoring
  ];

}

