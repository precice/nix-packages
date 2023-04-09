{
  description = "Flake for the precice-Nix research project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-generators }: let
    precice-system = {
      system = "x86_64-linux";
      modules = [ home-manager.nixosModules.home-manager ./configuration.nix ];
    };
    precice-system-virtualbox = precice-system // {
      modules = precice-system.modules ++ [{
        virtualbox = {
          memorySize = 2048;
          vmName = "preCICE-VM";
          params = {
            cpus = 2;
            vram = 64;
            graphicscontroller = "vmsvga"; # This is default
          };
        };
      }];
    };
  in {
    nixosConfigurations.precice-vm = nixpkgs.lib.nixosSystem precice-system;

    packages.x86_64-linux = {
      iso = nixos-generators.nixosGenerate (precice-system // { format = "iso"; });
      vagrant-vbox-image = nixos-generators.nixosGenerate (precice-system-virtualbox // { format = "vagrant-virtualbox"; });
      vm = nixos-generators.nixosGenerate (precice-system // { format = "vm"; });
    };
  };
}
