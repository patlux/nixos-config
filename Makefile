
UNAME := $(shell uname)
NIXNAME ?= mbpromax

.PHONY: setup fmt check update preview switch orbubu wsl

setup:
	git config core.hooksPath .githooks
	@echo "Git hooks installed"

fmt:
	nix fmt

check:
	nix fmt -- --check .
	nix flake check --no-build

update:
	nix flake update

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
	nix build ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo nixos-rebuild switch --flake ".#${NIXNAME}"
endif

orbubu:
	nix run home-manager/master -- switch --flake .#orbubu

wsl:
	nix build ".#nixosConfigurations.wsl.config.system.build.toplevel"
