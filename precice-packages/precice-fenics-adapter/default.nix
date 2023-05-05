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

  meta = {
    description = "preCICE-adapter for the open source computing platform FEniCS";
    homepage = "https://github.com/precice/fenics-adapter";
    license = with lib.licenses; [ lgpl3Only ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
