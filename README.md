# NixOS Precice VM

To build the VM, use `nixos-rebuild build-vm -I nixos-config=./nixos-vm.nix` or the flake based approach `nixos-rebuild build-vm --flake '.#precice-vm'`.
This will generate a symlink called `result` in the current directory.
To start the VM, run `./result/bin/run-precice-vm-vm`.

For accessing the single packages via `nix-shell`, you have to alter your `NIX_PATH` like this: `NIX_PATH=nixpkgs-overlays=./precice-packages/default.nix:$NIX_PATH nix-shell -p openfoam openfoam-wmake pkg-config precice`

## HPC Environment

This section is only relevant for the Simtech HPC of the University of Stuttgart.
It assumes a Linux installation.

In order to use the cluster, you have to apply, connect to the VPN, connect to a node via ssh and setup Nix.

1. Apply for the cluster

This won't be documented here.

2. Connect to the VPN:

Install `openconnect` and issue `sudo openconnect --user=st123456@stud.uni-stuttgart.de vpn.tik.uni-stuttgart.de`.
If `gopass` or another password store is installed, you can also let openconnect read the password from stdin: `gopass uni/st | sudo openconnect --user=st175425@stud.uni-stuttgart.de vpn.tik.uni-stuttgart.de --passwd-on-stdin`

3. Login via ssh

To make it easy to login, add the following to your `~/.ssh/config` file:

```sshconfig
# ~/.ssh/config
Host simtech-hpc
    Hostname ehlers-login.informatik.uni-stuttgart.de
    User st123456
```

4. Install Nix

Have a look at the `setup.sh` script in this repo and after understanding it, you can execute it on the simtech-hpc by running `bash setup.sh`.
This might take a few minutes.
Afterwards, you can use Nix by running `nix-static` (this might require you to open a new shell).
This also means, that in every command you want to use Nix, you'd have to substitute `nix` by `nix-static`.

5. Build the iso of the preCICE VM

Remember to use `nix-static` if you are running this on the simtech-hpc after installing nix via the `setup.sh` script.

`nix build '.#nixosConfigurations."precice-vm".config.system.build.iso'`

6. (Optional) Uninstall nix

Read, understand and run the `clean.sh` script in this repo.

Tip: You can disable the banner when logging in by executing a `touch ~/.hushlogin`.
