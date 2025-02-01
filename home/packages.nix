{ pkgs, ... }:

{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip # for neovim
    p7zip

    neovim
    eza
    pinentry-curses

    # for neovim
    tree-sitter
    fzf
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
    iotop # io monitoring
    iftop # network monitoring
  ];

}

