
ifneq ("$(wildcard .env)","")
include .env
export
endif

UNAME := $(shell uname)
NIXNAME ?= mbpromax
NIX_EXPERIMENTAL := --extra-experimental-features "nix-command flakes"

.PHONY: help setup fmt lint check audit update preview switch orbubu

help:
	@echo "Available commands:"
	@echo "  help    - Show this help message"
	@echo "  setup   - Install git hooks"
	@echo "  fmt     - Format nix files"
	@echo "  lint    - Lint nix files with statix"
	@echo "  check   - Run format check and flake check"
	@echo "  audit   - Scan entire repo for secrets with gitleaks"
	@echo "  update  - Update flake inputs"
	@echo "  preview - Preview system changes without applying"
	@echo "  switch  - Build and switch to new system configuration"
	@echo "  orbubu  - Build and switch to orbubu home configuration"
	@echo ""
	@echo "Local overrides: set NIXNAME in .env (see .env.example)"

setup:
	git config core.hooksPath .githooks
	@echo "Git hooks installed"

fmt:
	nix $(NIX_EXPERIMENTAL) fmt

lint:
	nix $(NIX_EXPERIMENTAL) run nixpkgs#statix -- check .

check:
	nix $(NIX_EXPERIMENTAL) fmt -- --ci
	nix $(NIX_EXPERIMENTAL) flake check --no-build

audit:
	@if ! command -v gitleaks >/dev/null 2>&1; then \
		echo "gitleaks not found — install with: nix profile install nixpkgs#gitleaks"; \
		exit 1; \
	fi
	gitleaks git --verbose

update:
	nix $(NIX_EXPERIMENTAL) flake update

preview:
ifeq ($(UNAME), Darwin)
	nix $(NIX_EXPERIMENTAL) build ".#darwinConfigurations.${NIXNAME}.system"
	nix store diff-closures /nix/var/nix/profiles/system ./result
else
	nixos-rebuild $(NIX_EXPERIMENTAL) build --flake ".#${NIXNAME}"
	nix store diff-closures /nix/var/nix/profiles/system ./result
endif

switch:
ifeq ($(UNAME), Darwin)
	nix $(NIX_EXPERIMENTAL) build ".#darwinConfigurations.${NIXNAME}.system"
	sudo ./result/sw/bin/darwin-rebuild $(NIX_EXPERIMENTAL) switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo nixos-rebuild $(NIX_EXPERIMENTAL) switch --flake ".#${NIXNAME}"
endif

orbubu:
	nix $(NIX_EXPERIMENTAL) run home-manager/master -- switch --flake .#orbubu
