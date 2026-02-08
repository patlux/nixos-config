{ pkgs, ... }:

{

  # --- Program modules (provide the binary + config integration) ---

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type file --hidden --exclude .git";
    fileWidgetCommand = "fd --type file --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type directory --hidden --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      # Sonokai palette
      "--color=fg:#e2e2e3,bg:#2c2e34,hl:#f39660"
      "--color=fg+:#e2e2e3,bg+:#363944,hl+:#f39660"
      "--color=info:#e7c664,prompt:#76cce0,pointer:#fc5d7c"
      "--color=marker:#9ed072,spinner:#b39df3,header:#7f8490"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Monokai Extended"; # closest built-in match to Sonokai
      style = "numbers,changes,header";
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git"
    ];
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };
  xdg.configFile."btop/btop.conf".force = true;

  programs.zsh.initContent = ''
    # Add mysql client to PATH if installed via brew
    if [ -d /opt/homebrew/opt/mysql-client/bin ]; then
      export PATH="$PATH:/opt/homebrew/opt/mysql-client/bin"
    fi
  '';

  # Packages that should be installed to the user profile.
  home.packages =
    (with pkgs; [
    gcc
    vim
    file
    wget
    autossh

    # archives
    zip
    xz
    neovim
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

    pinentry-curses
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
    libavif # avif image format
    k6

    # for neovim
    tree-sitter
    go
    gofumpt
    gopls
    cargo

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
    pass

    # not available on mac
    # iotop # io monitoring
    iftop # network monitoring

     gitleaks # secret scanning
     gh
     glab
   ])
     ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
       pkgs.libsecret
     ];

}
