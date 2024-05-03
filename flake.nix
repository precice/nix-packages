{
  description = "Flake for the precice-Nix research project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # This allows us to use the garnix binary cache which the GitHub CI job
  # copies the binaries to, so we don't have to build anything locally
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  # deadnix: skip
  outputs = { self, nixpkgs, home-manager, nixos-generators }: let
    precice-system-light = {
      system = "x86_64-linux";
      modules = [ home-manager.nixosModules.home-manager ./configuration-light.nix ];
    };
    precice-system-virtualbox-light = precice-system-light // {
      modules = precice-system-light.modules ++ [{
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
      config.permittedInsecurePackages = [
        "hdf5-1.10.9"
      ];
    };

    # This simply reads all defined names of the packages specified in the overlay, so it results in
    # a list of package names: [ "blacs" "dealii" ... ]
    precice-package-names = builtins.attrNames ((builtins.elemAt (import ./precice-packages) 1) null { callPackage = {}; });

    # This expands "dealii" to `{ dealii = pkgs.dealii; }`
    precice-packages = pkgs.lib.genAttrs precice-package-names (name: pkgs.${name});
  in rec {
    # Access by running `nixos-rebuild --flake .#precice-vm build`
    nixosConfigurations.precice-vm = nixpkgs.lib.nixosSystem precice-system;

    # Access by running `nix build .#<attribute>`
    packages.x86_64-linux = {
      # These are packages that are already available upstream.
      # We simply re-expose them to allow for easy access by the nix tools.
      inherit (pkgs) precice;
    } // precice-packages // { # Custom build packages for preCICE
      iso = nixos-generators.nixosGenerate (precice-system // { format = "iso"; });
      iso-light = nixos-generators.nixosGenerate (precice-system-light // { format = "iso"; });
      vagrant-vbox-image = nixos-generators.nixosGenerate (precice-system-virtualbox // { format = "vagrant-virtualbox"; });
      vagrant-vbox-image-light = nixos-generators.nixosGenerate (precice-system-virtualbox-light // { format = "vagrant-virtualbox"; });
      vm = nixos-generators.nixosGenerate (precice-system // { format = "vm"; });
      vm-light = nixos-generators.nixosGenerate (precice-system-light // { format = "vm"; });

      precice-simulation-environment = pkgs.stdenvNoCC.mkDerivation {
        name = "preCICE execution environment";
        version = "v202211.0";
        src = ./.;
        buildInputs = pkgs.lib.mapAttrsToList (_: value: value) precice-packages ++ [ pkgs.bash pkgs.gcc pkgs.openmpi ];
      };
    };

    # Access by running `nix run`
    apps.x86_64-linux.default = {
      type = "app";
      program = "${packages.x86_64-linux.vm}/bin/run-precice-vm-vm";
    };

    # Access by running `nix develop`
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = (import ./configuration.nix { inherit pkgs; inherit (nixpkgs) lib; config = null; }).environment.systemPackages;

      shellHook = ''
        source ${pkgs.openfoam}/bin/set-openfoam-vars
        source ${pkgs.precice-dune}/bin/set-dune-vars
        export LD_LIBRARY_PATH=${pkgs.precice-openfoam-adapter}/lib:$LD_LIBRARY_PATH
      '';
    };
  };
}
