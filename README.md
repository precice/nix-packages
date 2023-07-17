# NixOS Precice VM

<!-- INTRO, was das repo macht -->

## Getting Started

To build the precice-vm, the Nix binary is required.
We provide a setup script to get the Nix package manager if it is not already available.
After that you can use it to build either a qemu or vagrant virtual box VM image of the precice-vm or you can even build a bootable iso.

```
# 0. If nix is not already available, we first need to download it
# The easiest way is to use the ./setup.sh script provided by the repo, otherwise please see https://nixos.org/download
bash ./setup.sh
# After the script succeeded nix-static should be available
# 1. inside this repository you can now run to build a qemu vm image
nix build '.#vm'
# You can replace `vm` with
# - vagrant-vbox-image -- to build a vagrant virtual box image
# - iso                -- to build a bootable iso
```

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
