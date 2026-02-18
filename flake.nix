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

  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
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

      formatter = nixpkgs.lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

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

      # macOS

      darwinConfigurations = (mkDarwinHost "mbpromax") // (mkDarwinHost "mmm1");

    };
}
