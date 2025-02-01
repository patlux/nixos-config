{
  description = "My flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {

      # nixOS in UTM
      nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/nixos
          ./users/patwoz/nixos.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.users.patwoz = import ./users/patwoz/home.nix;
          }
        ];
      };

    };
  };
}
