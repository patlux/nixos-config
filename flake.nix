{
  description = "nixOS configurations of patwoz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      nixos-wsl,
      home-manager,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      mkApp = pkgs: name: script: {
        type = "app";
        program = "${pkgs.writeShellScriptBin name script}/bin/${name}";
      };

      mkDarwinHost = name: {
        ${name} = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            ./hosts/${name}
          ];
        };
      };
    in
    {

      formatter = nixpkgs.lib.genAttrs systems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

      checks = nixpkgs.lib.genAttrs systems (system: {
        formatting = nixpkgs.legacyPackages.${system}.runCommand "check-formatting" { } ''
          ${nixpkgs.legacyPackages.${system}.nixfmt-rfc-style}/bin/nixfmt --check ${./.} && touch $out
        '';
      });

      # Apps

      apps.aarch64-darwin =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        in
        {
          gc = mkApp pkgs "nix-gc" ''
            set -euo pipefail
            echo "Collecting garbage (>30 days)..."
            nix-collect-garbage --delete-older-than 30d
            echo ""
            echo "Optimising store..."
            nix store optimise
            echo ""
            echo "Store size: $(du -sh /nix/store 2>/dev/null | cut -f1)"
          '';

          info = mkApp pkgs "system-info" ''
            set -euo pipefail
            echo "System: $(readlink /nix/var/nix/profiles/system 2>/dev/null || echo "unknown")"
            echo ""
            echo "Recent generations:"
            darwin-rebuild --list-generations 2>/dev/null | tail -5 || true
            echo ""
            echo "Store size: $(du -sh /nix/store 2>/dev/null | cut -f1)"
            echo ""
            echo "Flake inputs:"
            nix flake metadata --json 2>/dev/null | ${pkgs.jq}/bin/jq -r \
              '.locks.nodes | to_entries[] | select(.value.locked.type == "github") | "  \(.key): \(.value.locked.owner)/\(.value.locked.repo) @ \(.value.locked.rev[0:8])"'
          '';
        };

      # NixOS

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/nixos
        ];
      };

      # Home Manager

      homeConfigurations.orbubu = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          ./hosts/orbubu/home.nix
        ];
      };

      # WSL

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            wsl = {
              enable = true;

              wslConf = {
                automount.root = "/mnt";
                network.generateResolvConf = false;
              };

              defaultUser = "patwoz";
              startMenuLaunchers = true;
            };

            system.stateVersion = "24.11";
          }
          home-manager.nixosModules.home-manager
          # ./hosts/wsl
        ];
      };

      # macOS

      darwinConfigurations = (mkDarwinHost "mbpromax") // (mkDarwinHost "mmm1");

    };
}
