{ pkgs, ... }:

{

  programs.fzf.enable = true;
  programs.fzf.defaultCommand = "fd --type file --hidden --exclude .git";

  # only if mysql is installed by brew
  programs.zsh.initContent = "
      export PATH=$PATH:/opt/homebrew/opt/mysql-client/bin
  ";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    gcc
    git
    vim
    wget
    file
    autossh

    # archives
    zip
    xz
    unzip # for neovim
    p7zip
    mkcert

    postgresql

    # kubernetes / cloud
    awscli2
    terraform
    skaffold
    redis
    eksctl
    k3d
    kubectl
    kubectx
    k9s
    tilt

    # old version
    # hurl # api tests

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
    libavif # avif image format
    k6

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

