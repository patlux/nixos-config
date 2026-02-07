{ pkgs, ... }:

let
  zenProfile = "tvhmrfo5.Default (release)";

  bitwardenXpi = pkgs.fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4664623/bitwarden_password_manager-2025.12.1.xpi";
    hash = "sha256-p6Ej7uTkD92K98DGckNzHdzDeuFJjPKCiZX0kFYAxR8=";
  };
in
{
  # Bitwarden extension — deployed to Zen profile extensions directory
  home.file."Library/Application Support/zen/Profiles/${zenProfile}/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi" =
    {
      source = bitwardenXpi;
      force = true;
    };
  # Zen Browser user.js — persistent preferences applied on every launch
  # Manages: privacy, security, telemetry, DNS, devtools, workspaces
  home.file."Library/Application Support/zen/Profiles/${zenProfile}/user.js" = {
    force = true;
    text = ''
      // Zen Browser - user.js (managed by nix/home-manager)
      // DO NOT EDIT — changes will be overwritten on next darwin-rebuild switch
      // Source: ~/.config/nixos/home/zen.nix

      // === Privacy & Security ===
      user_pref("browser.contentblocking.category", "strict");
      user_pref("dom.security.https_only_mode", true);
      user_pref("dom.security.https_only_mode_ever_enabled", true);
      user_pref("privacy.fingerprintingProtection", true);
      user_pref("privacy.trackingprotection.enabled", true);
      user_pref("privacy.trackingprotection.socialtracking.enabled", true);
      user_pref("privacy.trackingprotection.emailtracking.enabled", true);
      user_pref("privacy.trackingprotection.allow_list.convenience.enabled", false);
      user_pref("privacy.annotate_channels.strict_list.enabled", true);
      user_pref("privacy.bounceTrackingProtection.mode", 1);
      user_pref("privacy.query_stripping.enabled", true);
      user_pref("privacy.query_stripping.enabled.pbmode", true);
      user_pref("privacy.history.custom", true);
      user_pref("privacy.globalprivacycontrol.was_ever_enabled", true);
      user_pref("privacy.clearOnShutdown_v2.formdata", true);
      user_pref("network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation", true);

      // === Password Manager (disabled — using Bitwarden) ===
      user_pref("signon.rememberSignons", false);
      user_pref("signon.autofillForms", false);
      user_pref("signon.generation.enabled", false);
      user_pref("signon.management.page.breach-alerts.enabled", false);
      user_pref("signon.firefoxRelay.feature", "");
      user_pref("extensions.formautofill.addresses.enabled", false);
      user_pref("extensions.formautofill.creditCards.enabled", false);

      // === WebRTC Leak Prevention ===
      user_pref("media.peerconnection.ice.default_address_only", true);
      user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

      // === Telemetry & Data Collection (all disabled) ===
      user_pref("toolkit.telemetry.enabled", false);
      user_pref("toolkit.telemetry.unified", false);
      user_pref("toolkit.telemetry.archive.enabled", false);
      user_pref("toolkit.telemetry.newProfilePing.enabled", false);
      user_pref("toolkit.telemetry.updatePing.enabled", false);
      user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
      user_pref("toolkit.telemetry.bhrPing.enabled", false);
      user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
      user_pref("toolkit.telemetry.server", "data:,");
      user_pref("toolkit.coverage.opt-out", true);
      user_pref("datareporting.healthreport.uploadEnabled", false);
      user_pref("datareporting.policy.dataSubmissionEnabled", false);
      user_pref("app.shield.optoutstudies.enabled", false);
      user_pref("browser.discovery.enabled", false);
      user_pref("browser.ping-centre.telemetry", false);
      user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
      user_pref("browser.newtabpage.activity-stream.telemetry", false);

      // === Sponsored Content & Pocket (disabled) ===
      user_pref("extensions.pocket.enabled", false);
      user_pref("browser.newtabpage.activity-stream.showSponsored", false);
      user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
      user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
      user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);

      // === DNS over HTTPS (mode 2 = DoH first, fallback to system DNS) ===
      user_pref("network.trr.mode", 2);
      user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
      user_pref("doh-rollout.disable-heuristics", true);
      // Simplified: base domains cover all subdomains, mode 2 falls back anyway
      user_pref("network.trr.excluded-domains", "mueller.de,camel-yo.ts.net,patwoz.dev,stern-vector.ts.net,awsapps.com,ladfies-forum.de,jdx.dev,mmm1-fedora,flg,localhost-7-0-0");

      // === Performance & Network ===
      user_pref("browser.cache.disk.enable", false);
      user_pref("browser.tabs.min_inactive_duration_before_unload", 3600000);
      user_pref("browser.low_commit_space_threshold_percent", 100);
      user_pref("network.dns.disablePrefetch", true);
      user_pref("network.http.speculative-parallel-limit", 0);
      user_pref("network.prefetch-next", false);

      // === Search ===
      user_pref("browser.search.suggest.enabled", true);
      user_pref("browser.search.suggest.enabled.private", true);
      user_pref("browser.search.separatePrivateDefault", false);
      user_pref("browser.urlbar.placeholderName", "Google");
      user_pref("browser.urlbar.placeholderName.private", "Google");

      // === DevTools ===
      user_pref("devtools.cache.disabled", true);
      user_pref("devtools.toolbox.host", "right");
      user_pref("devtools.toolbox.previousHost", "bottom");
      user_pref("devtools.toolbox.splitconsole.open", true);
      user_pref("devtools.toolbox.splitconsoleHeight", 178);
      user_pref("devtools.netmonitor.persistlog", true);
      user_pref("devtools.netmonitor.ui.default-raw-response", true);
      user_pref("devtools.inspector.activeSidebar", "ruleview");
      user_pref("devtools.inspector.three-pane-enabled", false);
      user_pref("devtools.responsive.reloadNotification.enabled", false);
      user_pref("devtools.performance.recording.entries", 134217728);
      user_pref("devtools.performance.recording.features", "[\"screenshots\",\"js\",\"cpu\",\"memory\"]");
      user_pref("devtools.performance.recording.threads", "[\"GeckoMain\",\"Compositor\",\"Renderer\",\"DOM Worker\"]");

      // === Theme ===
      user_pref("extensions.activeThemeID", "firefox-compact-light@mozilla.org");

      // === Translation (disabled for de + en) ===
      user_pref("browser.translations.automaticallyPopup", false);
      user_pref("browser.translations.mostRecentTargetLanguages", "en,de");
      user_pref("browser.translations.neverTranslateLanguages", "de,en");

      // === Misc ===
      user_pref("full-screen-api.approval-required", true);
      user_pref("print_printer", "Mozilla Save to PDF");
      user_pref("pdfjs.enableAltText", true);
      user_pref("pdfjs.enableAltTextForEnglish", true);
      user_pref("browser.ml.enable", true);

      // === Zen Workspaces ===
      user_pref("zen.workspaces.force-container-workspace", true);
      user_pref("zen.workspaces.continue-where-left-off", true);
      user_pref("zen.workspaces.separate-essentials", false);
      user_pref("zen.welcome-screen.seen", true);
      user_pref("zen.view.compact.enable-at-startup", false);
    '';
  };
}
