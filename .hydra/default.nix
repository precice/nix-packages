{ declInput, projectName, ... }: let
  defaultJobset = {
    type = 0;
    enabled = 1;
    hidden = false;
    description = "Uniprojekt von Simon und Max";
    nixexprinput = "src";
    nixexprpath = ".hydra/release.nix";
    checkinterval = 120;
    schedulingshares = 250;
    enableemail = false;
    emailoverride = "";
    keepnr = 3;
    inputs = {};
  };

  jobsets = {
    preciceJobset = {
      inputs = {
        src = {
          type = "git";
          value = "https://github.com/precice/nix-packages.git";
          emailresponsible = false;
        };
        nixpkgs = {
          type = "git";
          value = "https://github.com/nixos/nixpkgs release-22.11";
          emailresponsible = false;
        };
      };
    };
  };
in {
  jobsets = derivation {
    name = "forschungsprojekt-spec.json";
    system = builtins.currentSystem;

    builder = "/bin/sh";
    args = [
      (builtins.toFile "spec-builder.sh" ''
        echo '${builtins.toJSON (builtins.mapAttrs (_: inputs: defaultJobset // inputs) jobsets)}' > "$out"
      '')
    ];
  };
}
