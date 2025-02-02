# Setup a new macOS

## Setup

- Language: English
- Country/Region: Germany
- Written/Spoken language: Customize Settings
- Preferred Language: English
- Input Sources: "+" -> "German" -> "ABC QWERTZ" (Remove German and US from the lis)
- Skip Backups
- Account name: patwoz
- Enable Location Services (Important for FindMe later)
- Skip Screen Time
- Skip Siri

## After Setup (Desktop)

### Activate FileVault

Open System Settings and make sure FileVault is active.

### (Optional) VirtualBuddy

If you do this on "VirtualBuddy", don't forget to start "VirtualBuddyGuest":

1. Open Finder
2. Open "Guest" under "Locations" in the left side menu
3. Run "VirtualBuddyGuest"

For Copy/Paste between Host and Virtual Machine.

### Install Xcode command line tools

Open Terminal via Spotlight (CMD + Space)

Install xcode command line tools

```sh
xcode-select --install
sudo xcode-select --switch /Library/Developer/CommandLineTools

# If Xcode is installed
sudo xcodebuild -license
```

### Install tools

Setup `llm`:

```sh
uv tool install llm
llm install llm-cmd
llm install llm-jq
llm install llm-deepseek
llm keys set deepseek
# <Paste key here>
```

### Setup Keyboard

#### Hide Menu Bar Entry

1. `System Settings`
2. `Keyboard`
3. `Input Sources` `Edit...`
4. Uncheck `Show Input menu in menu bar`

#### Raycast

`System Settings` > `Keyboard` > `Keyboard Shortcuts...`

Replace Spotlight with Raycast

1. Disable spotlight shortcut
   ![CleanShot 2024-02-10 at 00 49 53@2x](https://github.com/patlux/dotfiles/assets/4481570/1ae0b66d-18c0-482d-94f8-71f8a2542603)
2. Open Raycast and setup shortcut

#### Dygma Keyboard

**Fix keyboard type**

macOS won't detect the correct german quertz keyboard with the `<>` keys at the first.

To fix this run:

```sh
rm -f /Library/Preferences/keyboardtype.plist
```

Now reboot. After reboot:

`System Settings` > `Keyboard` > `Change Keyboard Type...` > Finish the process

**Swap `Option` and `Command` key**

`System Settings` > `Keyboard` > `Keyboard Shortcuts...`

![CleanShot 2024-03-12 at 17 04 06](https://github.com/patlux/dotfiles/assets/4481570/c3f22bd9-ef08-48fe-9985-e5f66388e8ac)

# Setup tailscale

This is required for the next steps. Don't skip.

1. Open Tailscale (via Raycast)
2. Login

### Setup bitwarden

This is required for the next steps. Don't skip.

1. Open Bitwarden
2. Choose Self-Hosted Environment
3. Enter the URL `https://syno.camel-yo.ts.net:7277`
4. Open Safai > Settings > Extensions > Download the Bitwarden Extension

### Setup home folder

gpg, .ssh, .npmrc, .yarnrc

> See `./BACKUP_MACOS.md`

```sh
cd ~/
duplicacy list
# Enter password from "Synology NAS (Web/SSH)" when asking for SAMBA password
# Enter password from "duplicacy" when asking for storage password
duplicacy restore -r <revision> "*"
# with overwrite existing files:
duplicacy restore -overwrite -r <revision> "*"
```

### Setup dev folder

> See `./BACKUP_MACOS.md`

```sh
cd ~/dev
duplicacy list
duplicacy restore -r <revision> "piparo.tech/*"
```

### Setup ARC

1. Open ARC
2. Settings
3. Login

### Setup Android

1. Launch Android Studio (via Raycast)
2. Make the setup
3. This will install a initial sdk under `~/Library/Android/sdk`
4. "Settings..." -> "Languages & Frameworks" -> "Android SDK"
5. Checkmark "Android SDK Command-line Tools (latest)"
6. Apply

### Setup Mounts

1. Open Finder
2. Open "Go" > "Connect to server..."
3. Enter `afp://syno.camel-yo.ts.net`
4. Authenticate

### Other

#### Install "Apple WWDR certificate"

Download [Certificate](https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer)

```sh
cd ~/Downloads
sudo security import AppleWWDRCAG3.cer -k /Library/Keychains/System.keychain
```

This fixes `Distribution certificate with fingerprint EAF3A00C1FC18283CACFEDC21AD6BB37EB993438 hasn't been imported successfully`
