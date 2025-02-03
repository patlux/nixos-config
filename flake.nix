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
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }: {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/nixos
      ];
    };

    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/wsl
      ];
    };

    darwinConfigurations.mbpromax = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
	        home-manager.darwinModules.home-manager
          ./hosts/mbpromax
        ];
    };

  };
}
