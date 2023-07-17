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
    precice-system-light = {
      system = "x86_64-linux";
      modules = [ home-manager.nixosModules.home-manager ./configuration-light.nix ];
    };
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
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = import ./precice-packages;
      config.allowUnfree = true;
    };

    # This simply reads all defined names of the packages specified in the overlay, so it results in
    # a list of package names: [ "blacs" "dealii" ... ]
    precice-package-names = builtins.attrNames ((builtins.elemAt (import ./precice-packages) 1) null { callPackage = arg1: arg2: {}; });

    # This expands "dealii" to `{ dealii = pkgs.dealii; }`
    precice-packages = pkgs.lib.genAttrs precice-package-names (name: pkgs.${name});
  in rec {
    nixosConfigurations.precice-vm = nixpkgs.lib.nixosSystem precice-system;

    packages.x86_64-linux = {
      # These are packages that are already available upstream.
      # We simply re-expose them to allow for easy access by the nix tools.
      inherit (pkgs) precice;
    } // precice-packages // { # Custom build packages for preCICE
      iso = nixos-generators.nixosGenerate (precice-system // { format = "iso"; });
      vagrant-vbox-image = nixos-generators.nixosGenerate (precice-system-virtualbox // { format = "vagrant-virtualbox"; });
      vm = nixos-generators.nixosGenerate (precice-system // { format = "vm"; });
      vm-light = nixos-generators.nixosGenerate (precice-system-light // { format = "vm"; });
    };

    hydraJobs = packages;

    apps.x86_64-linux.default = {
      type = "app";
      program = "${packages.x86_64-linux.vm}/bin/run-precice-vm-vm";
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = (import ./configuration.nix { inherit pkgs; lib = nixpkgs.lib; }).environment.systemPackages;

      shellHook = ''
        source ${pkgs.openfoam}/bin/set-openfoam-vars
        export LD_LIBRARY_PATH=${pkgs.precice-openfoam-adapter}/lib:$LD_LIBRARY_PATH
      '';
    };
  };
}
