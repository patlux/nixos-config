{ pkgs, ... }:

let
  wtp = pkgs.buildGoModule rec {
    pname = "wtp";
    version = "2.9.0";

    src = pkgs.fetchFromGitHub {
      owner = "satococoa";
      repo = "wtp";
      rev = "v${version}";
      hash = "sha256-IWDuTYwwYrtvUYDxFnN+LuK4T6rd2vd5N0AYy8+YDMk=";
    };

    vendorHash = "sha256-wX6TeALJojynP4ocOR45WkayVVwvTr2LUbfAxuns9SM=";
    subPackages = [ "cmd/wtp" ];
    doCheck = false;
  };

  piCodingAgent = pkgs.buildNpmPackage rec {
    pname = "pi-coding-agent";
    version = "0.72.0";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
      hash = "sha256-u1EN3lv6kj0Y/md/fzXVPwlQAOeNo8f24Fx0M6CqtRg=";
    };

    npmDepsHash = "sha256-StR9DAPHUyKAKpP8VkvHR09HgWAlbZYZ/3X2Esjv+3g=";
    nodejs = pkgs.nodejs_22;
    postPatch = ''
      cp ${./pi-coding-agent-package-lock.json} package-lock.json
    '';
    dontNpmBuild = true;
    postInstall = ''
      mv "$out/bin/pi" "$out/bin/pi-node"

      cat > "$out/bin/pi" <<EOF
      #!${pkgs.runtimeShell}
      exec ${pkgs.bun}/bin/bun "$out/lib/node_modules/@mariozechner/pi-coding-agent/dist/cli.js" "\$@"
      EOF
      chmod +x "$out/bin/pi"
    '';

    meta = {
      description = "Minimal terminal coding harness";
      homepage = "https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent";
      license = pkgs.lib.licenses.mit;
      mainProgram = "pi";
    };
  };

  fffMcpTarget =
    {
      aarch64-darwin = {
        target = "aarch64-apple-darwin";
        hash = "sha256-6esM7FhW14swOCyT5Uv7/mhUe7p6Wvh06XWqWcSQElI=";
      };
      aarch64-linux = {
        target = "aarch64-unknown-linux-musl";
        hash = "sha256-5ewAQGlud21LZR6I9Ckj/MGHz19TCS1syRPK3n992Gs=";
      };
      x86_64-linux = {
        target = "x86_64-unknown-linux-musl";
        hash = "sha256-tizTYiFxNvPLgWNILrLI6hBumRAm2cL5EuZBqDClbBg=";
      };
    }
    .${pkgs.stdenv.hostPlatform.system}
      or (throw "Unsupported system for fff-mcp: ${pkgs.stdenv.hostPlatform.system}");

  fffMcp = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "fff-mcp";
    version = "0.6.4";

    src = pkgs.fetchurl {
      url = "https://github.com/dmtrKovalenko/fff.nvim/releases/download/v${version}/fff-mcp-${fffMcpTarget.target}";
      hash = fffMcpTarget.hash;
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm755 "$src" "$out/bin/fff-mcp"
    '';

    meta = {
      description = "FFF MCP server for file and grep search";
      homepage = "https://github.com/dmtrKovalenko/fff.nvim";
      license = pkgs.lib.licenses.mit;
      mainProgram = "fff-mcp";
      platforms = builtins.attrNames {
        aarch64-darwin = null;
        aarch64-linux = null;
        x86_64-linux = null;
      };
    };
  };
in
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
      google-cloud-sdk

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
      jira-cli-go
      fffMcp
      piCodingAgent
      wtp
    ])
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.libsecret
    ];

}
