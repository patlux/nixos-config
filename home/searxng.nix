{
  config,
  lib,
  pkgs,
  ...
}:

let
  port = 8888;
  bindAddress = "127.0.0.1";
  baseUrl = "http://${bindAddress}:${toString port}";
  settingsPath = "${config.xdg.configHome}/searxng/settings.yml";
  keychainService = "SEARXNG_SECRET";
  keychainAccount = config.home.username;
  logDir = "${config.home.homeDirectory}/Library/Logs/searxng";

  searxngLocal = pkgs.writeShellApplication {
    name = "searxng-local";
    runtimeInputs = [ pkgs.openssl ];
    text = ''
      set -euo pipefail

      security_bin="/usr/bin/security"
      if [[ ! -x "$security_bin" ]]; then
        echo "macOS security CLI not found; cannot read ${keychainService} from Keychain" >&2
        exit 1
      fi

      if SEARXNG_SECRET="$($security_bin find-generic-password -a "${keychainAccount}" -s "${keychainService}" -w 2>/dev/null)"; then
        :
      else
        SEARXNG_SECRET="$(openssl rand -hex 32)"
        "$security_bin" add-generic-password \
          -a "${keychainAccount}" \
          -s "${keychainService}" \
          -w "$SEARXNG_SECRET" \
          -U \
          >/dev/null
      fi

      export SEARXNG_SETTINGS_PATH="${settingsPath}"
      export SEARXNG_SECRET

      exec ${pkgs.searxng}/bin/searxng-run
    '';
  };
in
{
  home = {
    packages = [ pkgs.searxng ];

    sessionVariables = {
      SEARXNG_URL = baseUrl;
    };

    file = {
      ".pi/agent/extensions/searxng-search.js" = {
        force = true;
        source = ./files/pi/agent/extensions/searxng-search.js;
      };

      "Library/Logs/searxng/.keep".text = "";
    };
  };

  xdg.configFile."searxng/settings.yml" = {
    force = true;
    text = ''
      use_default_settings:
        engines:
          keep_only:
            - duckduckgo
            - wikipedia
            - github
            - npm
            - mdn
            - stackoverflow
            - pypi
            - nixos wiki
            - crates.io
            - pkg.go.dev
            - rubygems

      general:
        instance_name: "local-searxng"
        enable_metrics: false

      search:
        safe_search: 0
        autocomplete: ""
        default_lang: "en-US"
        formats:
          - html
          - json

      server:
        bind_address: "${bindAddress}"
        port: ${toString port}
        base_url: false
        limiter: false
        public_instance: false
        image_proxy: false
        method: "GET"

      outgoing:
        request_timeout: 5.0
        pool_connections: 20
        pool_maxsize: 10
        enable_http2: true

      ui:
        query_in_title: false
        default_theme: simple

      engines:
        - name: npm
          disabled: false
        - name: nixos wiki
          disabled: false
        - name: crates.io
          disabled: false
        - name: pkg.go.dev
          disabled: false
    '';
  };

  launchd.agents.searxng = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${searxngLocal}/bin/searxng-local" ];
      KeepAlive = {
        Crashed = true;
        SuccessfulExit = false;
      };
      ProcessType = "Background";
      RunAtLoad = true;
      StandardOutPath = "${logDir}/launchd-stdout.log";
      StandardErrorPath = "${logDir}/launchd-stderr.log";
    };
  };
}
