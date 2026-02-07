
UNAME := $(shell uname)
NIXNAME ?= mbpromax

setup:
	git config core.hooksPath .githooks
	@echo "Git hooks installed"

preview:
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIXNAME}.system"
	nix store diff-closures /nix/var/nix/profiles/system ./result
else
	nixos-rebuild build --flake ".#${NIXNAME}"
	nix store diff-closures /nix/var/nix/profiles/system ./result
endif

switch:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

orbubu:
	nix run home-manager/master -- switch --flake .#orbubu

wsl:
	nix build ".#nixosConfigurations.wsl.config.system.build.toplevel"
