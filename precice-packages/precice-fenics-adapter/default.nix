{ lib, fetchFromGitHub, python3, precice, pyprecice, fenics, openmpi, openssh, pkg-config }:
python3.pkgs.buildPythonPackage rec {
  pname = "precice-fenics-adapter";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "fenics-adapter";
    rev = "v${version}";
    hash = "sha256-MVFuQn/9282ufjZEF7NhIDPycoDbvTWof1KVPTB/Crs=";
  };

  nativeBuildInputs = [ openmpi openssh pkg-config ];
  propagatedBuildInputs = with python3.pkgs; [
    precice
    pyprecice
    fenics

    scipy
  ];
  checkInputs = with python3.pkgs; [ pytest ];

  # TODO(conni2461): Remove once (two tests still fail
  doCheck = false;

  DIJITSO_CACHE_DIR = "/tmp";
}
