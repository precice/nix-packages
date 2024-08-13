{ declInput, projectName, ... }:
let
  jobsets = {
    flakeJobset = {
      enabled = 1;
      hidden = false;
      description = "Research project for building and packaging preCICE adapters and their solvers using nix";
      type = 1;
      flake = "github:precice/nix-packages";
      checkinterval = 120;
      schedulingshares = 250;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      inputs = { };
    };
  };
in
{
  jobsets = derivation {
    name = "forschungsprojekt-spec.json";
    system = builtins.currentSystem;

    builder = "/bin/sh";
    args = [
      (builtins.toFile "spec-builder.sh" ''
        echo '${builtins.toJSON jobsets}' > "$out"
      '')
    ];
  };
}
