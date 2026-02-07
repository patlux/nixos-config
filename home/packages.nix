{ pkgs, ... }:

{

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.fzf.defaultCommand = "fd --type file --hidden --exclude .git";

  programs.zsh.initContent = ''
    # Add mysql client to PATH if installed via brew
    if [ -d /opt/homebrew/opt/mysql-client/bin ]; then
      export PATH="$PATH:/opt/homebrew/opt/mysql-client/bin"
    fi
  '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    gcc
    git
    vim
    file
    wget
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

    dnsutils # `dig` + `nslookup`

    which
    tree
    gnused
    gnutar
    gnumake
    gawk
    zstd
    gnupg

    btop # replacement of htop/nmon
    # not available on mac
    # iotop # io monitoring
    iftop # network monitoring

    gitleaks # secret scanning
  ];

}
