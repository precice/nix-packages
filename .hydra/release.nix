let
  # This is the raw overlay
  precicePkgs = import ../precice-packages;

  # This imports the nixpkgs with our precice overlay
  pkgs = import <nixpkgs> {
    config.allowUnfree = true;
    overlays = precicePkgs;
  };

  # Extract attrSets
  names = builtins.attrNames ((builtins.elemAt precicePkgs 1) {} {});

  # Generate attrs in form `packagename = pkgs.packagename;`
  packages = builtins.listToAttrs (builtins.map (name: { inherit name; value = pkgs."${name}"; }) names);

  # $ NIXOS_CONFIG=$PWD/configuration.nix nix repl '<nixpkgs/nixos>'
  # nix-repl> config.system.build.vm
  # vm = (pkgs.nixos { configuration}).config.system.build.vm
  vm = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [
      ../configuration.nix
      {
        nixpkgs.pkgs = pkgs;
      }
    ];
  }).config.system.build.vm;

in
  # These are the separate jobs that are generated
  packages // { inherit vm; }
