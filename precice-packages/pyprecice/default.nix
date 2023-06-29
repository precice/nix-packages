{ lib
, fetchFromGitHub
, python3
, precice
, pkg-config
, openmpi
, openssh
}:

python3.pkgs.buildPythonPackage rec {
  pname = "pyprecice";
  version = "2.5.0.2";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "python-bindings";
    rev = "v${version}";
    hash = "sha256-ppDilMwRxVsikTFQMNRYL0G1/HvVomz2S/2yx43u000=";
  };

  nativeBuildInputs = with python3.pkgs; [
    cython
    openmpi
    openssh
    pkg-config
  ];

  propagatedBuildInputs = [
    python3.pkgs.numpy
    python3.pkgs.mpi4py
    precice
    python3.pkgs.pkgconfig
  ];

  doCheck = false;

  meta = with lib; {
    description = "Python language bindings for preCICE";
    homepage = "https://github.com/precice/python-bindings";
    license = [ licenses.lgpl3Only ];
    maintainers = with maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
