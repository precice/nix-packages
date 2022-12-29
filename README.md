# NixOS Precice VM

To build the VM, use `nixos-rebuild build-vm -I nixos-config=./nixos-vm.nix` or the flake based approach `nixos-rebuild build-vm --flake '.#precice-vm'`.
This will generate a symlink called `result` in the current directory.
To start the VM, run `./result/bin/run-precice-vm-vm`.

For accessing the single packages via `nix-shell`, you have to alter your `NIX_PATH` like this: `NIX_PATH=nixpkgs-overlays=./precice-packages/default.nix:$NIX_PATH nix-shell -p openfoam openfoam-wmake pkg-config precice`
