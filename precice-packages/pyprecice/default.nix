{ lib, fetchFromGitHub, python3, precice, fenics, pkg-config, openmpi, openssh }:
python3.pkgs.buildPythonPackage rec {
  pname = "pyprecice";
  version = "2.5.0.1";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "python-bindings";
    rev = "v${version}";
    hash = "sha256-0dxWtlN3x3orBgtCTxTsql39+MBVsgeHO7gXjOO8qcA=";
  };

  nativeBuildInputs = with python3.pkgs; [ cython openmpi openssh pkg-config ];

  propagatedBuildInputs = [
    precice
    python3.pkgs.numpy
    python3.pkgs.pkgconfig
    python3.pkgs.mpi4py
  ];

  doCheck = false;
}
