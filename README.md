# nixos-config

My personal nixos configurations for my linux and macOS machines.

[![Twitter Follow](https://img.shields.io/twitter/follow/de_patwoz?style=social)](https://twitter.com/de_patwoz)

## Bootstrap a new machine

1. [Install nix](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer) (Make sure to read also https://github.com/nix-darwin/nix-darwin: At this time it's recommended **not** to use the `Determinate Nix`)
2. Run:

```sh
# Wherever you want
git clone https://github.com/patlux/nixos-config
cd nixos-config

# On macOS install brew first: https://brew.sh/

# on Macbook Pro
make
# Additional steps in ./SETUP_MACOS.md

# on NixOS
NIXNAME=nixos make
```

## Maintenance

TODO

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
