{
  description = "Flake for the precice-Nix research project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager }: {

    nixosConfigurations.precice-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ home-manager.nixosModules.home-manager ./configuration.nix ];
    };
  };
}
