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

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs: {
    nixosConfigurations = {

      # nixOS in UTM
      nixos = let
        username = "patwoz";
        specialArgs = {inherit username;};
      in nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/nixos
          ./users/${username}/nixos.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = inputs // specialArgs;
            home-manager.users.${username} = import ./users/${username}/home.nix;
          }
        ];
      };

    };

    darwinConfigurations.mbpromax = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          # ./users/patwoz/nixos.nix

	        home-manager.darwinModules.home-manager
          ./hosts/mbpromax
        ];
    };

  };
}
