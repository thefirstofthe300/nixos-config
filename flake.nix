{
  description = "Flake for the-brain";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-25.05"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Use system packages list for their inputs
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let globals = { user = "dseymour"; };
    in {
      nixosConfigurations = {
        the-brain = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ ./configuration.nix home-manager.nixosModules.home-manager ];
        };
      };
    };
}
