{
  lib,
  fetchPypi,
  python3,
  precice,
  fenics,
  fenics-mshr,
  pyprecice,
  openmpi,
  openssh,
  pkg-config,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "precice-fenics-adapter";
  version = "1.4.0";

  src = fetchPypi {
    pname = "fenicsprecice";
    inherit version;
    hash = "sha256-ux5qi4SGGHETbldfEiT8H/7Pvmn2uvQwDFB1wi/pAKI=";
  };

  nativeBuildInputs = [
    openmpi
    openssh
    pkg-config
  ];
  propagatedBuildInputs = [
    precice
    pyprecice

    fenics
    fenics-mshr
    python3.pkgs.scipy
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
