{
  description = "nixOS configurations of patwoz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, nixos-wsl, home-manager, ... }: {

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

  };
}
