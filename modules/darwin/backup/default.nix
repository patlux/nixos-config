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
-*/target/
-*/Pods/
-*/android/app/build/
-*.apk
-*.aab
-*.ipa
-*.app/
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
