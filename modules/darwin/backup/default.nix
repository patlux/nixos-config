{ pkgs, ... }:

{
  # setup duplicacy
  home.packages = with pkgs; [
    duplicacy
  ];

  home.file.".duplicacy/filters".text = ''
    +.ssh/*
    +.npmrc
    +.yarnrc.yml
    +.zshrc_secret
    +.kube/
    +.kube/*
    +.gnupg/
    +.gnupg/private-keys-v1.d/
    +.gnupg/private-keys-v1.d/*
    +.gnupg/gpg-agent.conf
    +.gnupg/pubring.kbx
    +Library/
    +Library/Application Support/
    +Library/Application Support/Viscosity/*
    +Library/Application Support/
    +Library/Application Support/Google/
    +Library/Application Support/Google/Chrome/
    +Library/Application Support/Google/Chrome/Profile */*
    +Library/Application Support/Google/Chrome/Default/*
    +Library/Application Support/com.tinyapp.TablePlus/
    +Library/Application Support/com.tinyapp.TablePlus/Data
    +Library/Application Support/com.tinyapp.TablePlus/Data/*
    +Library/Application Support/Insomnium/
    +Library/Application Support/Insomnium/*.db
    +Library/Application Support/Insomnium/Preferences
    +Library/Application Support/Insomnium/Cookies
    +Library/Application Support/Insomnium/plugins
    +Library/Application Support/Insomnium/plugins/*
    +Library/Application Support/zen/
    +Library/Application Support/zen/profiles.ini
    +Library/Application Support/zen/installs.ini
    +Library/Application Support/zen/Profiles/
    +Library/Application Support/zen/Profiles/*/
    +Library/Application Support/zen/Profiles/*/*.sqlite
    +Library/Application Support/zen/Profiles/*/*.json
    +Library/Application Support/zen/Profiles/*/*.jsonlz4
    +Library/Application Support/zen/Profiles/*/*.js
    +Library/Application Support/zen/Profiles/*/*.db
    +Library/Application Support/zen/Profiles/*/key4.db
    +Library/Application Support/zen/Profiles/*/logins.json
    +Library/Application Support/zen/Profiles/*/cert9.db
    +Library/Application Support/zen/Profiles/*/extensions/
    +Library/Application Support/zen/Profiles/*/extensions/*
    +Library/Application Support/zen/Profiles/*/bookmarkbackups/
    +Library/Application Support/zen/Profiles/*/bookmarkbackups/*
    +Library/Preferences/
    +Library/Preferences/com.viscosityvpn.Viscosity.plist
    -*
  '';

  home.file.".duplicacy/preferences".text = ''
    [
        {
            "name": "default",
            "id": "home",
            "repository": "",
            "storage": "smb://patwoz@syno.camel-yo.ts.net/Root/Backups/home",
            "encrypted": true,
            "no_backup": false,
            "no_restore": false,
            "no_save_password": false,
            "nobackup_file": "",
            "keys": null,
            "filters": "",
            "exclude_by_attribute": false
        }
    ]
  '';

  home.file."dev/.duplicacy/filters".text = ''
    -*/node_modules/
    -*/vendor/
    -*/.build/
    -*/build/
    -*/.build/
    -*/dist/
    -*/.zig-cache/
    -*/zig-out/
    -*/target/
    -*/Pods/
    -*/android/app/build/
    -*.apk
    -*.aab
    -*.ipa
    -*.app/
    -*.tmp
    -*.swp
    -*.swo
    -*.log
    -*.class
    -*.DS_Store
    -*.idea/
    -*.vscode/
  '';

  home.file."dev/.duplicacy/preferences".text = ''
    [
        {
            "name": "default",
            "id": "dev",
            "repository": "",
            "storage": "smb://patwoz@syno.camel-yo.ts.net/Root/Backups/dev",
            "encrypted": false,
            "no_backup": false,
            "no_restore": false,
            "no_save_password": false,
            "nobackup_file": "",
            "keys": null,
            "filters": "",
            "exclude_by_attribute": false
        }
    ]
  '';
}
