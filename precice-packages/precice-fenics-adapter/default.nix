{
  lib,
  fetchFromGitHub,
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

  src = fetchFromGitHub {
    owner = "precice";
    repo = "fenics-adapter";
    rev = "v${version}";
    hash = "sha256-tddOcFZ/ls6fV+prtHQSIJmJ04eU9voj7ZyXEzEU6fA=";
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
  pythonImportsCheck = [ "fenicsprecice" ];
  nativeCheckInputs = with python3.pkgs; [ pytest ];

  DIJITSO_CACHE_DIR = "/tmp";

  meta = {
    description = "preCICE-adapter for the open source computing platform FEniCS";
    homepage = "https://github.com/precice/fenics-adapter";
    license = with lib.licenses; [ lgpl3Only ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
