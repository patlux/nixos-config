# nixos-config

My personal nixos configurations for my linux and macOS machines.

[![Twitter Follow](https://img.shields.io/twitter/follow/de_patwoz?style=social)](https://twitter.com/de_patwoz)

## Bootstrap a new machine

### 1. Install Nix

**macOS (nix-darwin compatible):**

Use the official Nix installer (multi-user):

```sh
curl -L https://nixos.org/nix/install | sh
```

**Linux (NixOS):**

Follow the [NixOS installation guide](https://nixos.org/download.html).

**Important:** The `Determinate Nix Installer` is currently **not recommended** for macOS if you plan to use `nix-darwin`. See [nix-darwin compatibility notes](https://github.com/nix-darwin/nix-darwin).

After installation, restart your shell or run:

```sh
. ~/.nix-profile/etc/profile.d/nix.sh
```

Verify the installation:

```sh
nix --version
```

### 2. Install Homebrew (macOS only)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Clone and configure

```sh

# Clone this repository
git clone https://github.com/patlux/nixos-config ~/.config/nixos
cd ~/.config/nixos

# Setup git hooks
make setup

# Build and apply configuration
# For macOS (default host: mbpromax)
make switch

# For other hosts, specify NIXNAME:
# NIXNAME=mbp14m1 make switch    # MacBook Pro M1 14"
# NIXNAME=mmm1 make switch       # Mac Mini M1
# NIXNAME=nixos make switch      # NixOS machine
```

**Note for macOS:** See [SETUP_MACOS.md](./SETUP_MACOS.md) for additional macOS-specific setup steps.

## Maintenance

Run `make` to see all available commands.

Common workflows:

```sh
make audit    # Scan repo for leaked secrets (gitleaks)
make update   # Update flake inputs
make preview  # Preview changes before applying
make switch   # Build and apply system configuration
```

## Tools

### [wezterm](https://wezfurlong.org/wezterm)

`wezterm` is my primary used terminal. It has built-in support for tabs and it's known for it's speed.

| Shortcut               | Description                              |
| ---------------------- | ---------------------------------------- |
| `ctrl` + `,`           | Switch to previous tab                   |
| `ctrl` + `shift` + `,` | Move tab backwards                       |
| `ctrl` + `.`           | Switch to next tab                       |
| `ctrl` + `shift` + `,` | Move tab forwards                        |
| `cmd` + `t`            | Create new tab                           |
| `cmd` + `n`            | Create new window with current directory |

### System Mappings

Controlled by [hidutil](https://developer.apple.com/library/archive/technotes/tn2450/_index.html).

| Shortcut                             | Description                                                       |
| ------------------------------------ | ----------------------------------------------------------------- |
| `right cmd` mapped to `right option` | To enter `@` (because Keychron v2 doesn't have a right option key |
| `capslock` mapped to `esc`           | Easier access to `esc`                                            |
| `esc` mapped to `^`                  | Easier to enter something like `^g` :)                            |

Use the [online tool](https://hidutil-generator.netlify.app) to generate the json.

### Adblock

To block ads I'm using [MattiSG/adblock](https://github.com/MattiSG/adblock).

## Author

Created by [Patrick Wozniak](https://patwoz.dev)

I'm a software developer who discovered my passion for coding at the age of 16, and since then, I've become an experienced frontend engineer with a strong focus on JavaScript/TypeScript and React/React Native.
