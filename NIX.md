# nix

## Setup new machine

### Home-Manager (only)

```sh
mkdir -p hosts/<hostname>

cd hosts/<hostname>
touch home.nix
# Insert configuration into the above file

# Adding entry point to ./flake.nix

nix run home-manager/master -- switch --flake .#<hostname>
```
