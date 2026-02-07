{
  description = "nixOS configurations of patwoz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, nix-darwin, nixos-wsl, home-manager, ... }: {

    formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ] (system:
      nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
    );

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

    darwinConfigurations.mbpromax = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
	        home-manager.darwinModules.home-manager
          ./hosts/mbpromax
        ];
    };

    darwinConfigurations.mmm1 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
	        home-manager.darwinModules.home-manager
          ./hosts/mmm1
        ];
    };

  };
}
