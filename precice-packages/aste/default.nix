{ lib
, pkgs
, stdenv
, fetchFromGitHub
, cmake
, gcc
, precice
, boost
, vtk_9
, libGL
, libX11
, metis
, openmpi
, python3
, openssh
}:
let
  python_vtk_9 = python3.pkgs.toPythonModule (vtk_9.override {
    pythonInterpreter = python3;
    enablePython = true;
  });
in
stdenv.mkDerivation rec {
  pname = "precice-aste";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "aste";
    rev = "v${version}";
    sha256 = "sha256-hYqpM59NJGIOefMBFS2zd39lQyGoyU0ypJVdCzSsGT8=";
  };

  nativeBuildInputs = [
    cmake
    gcc

    precice
    boost
    vtk_9
    libGL
    libX11
    metis
    python3
    python3.pkgs.numpy
    python3.pkgs.sympy
    python_vtk_9
  ];
  propagatedBuildInputs = with python3.pkgs; [
    numpy
    sympy
    scipy
    python_vtk_9
    openmpi
  ];

  doCheck = true;
  checkInputs = [ openssh python3.pkgs.jinja2 ];
  preCheck = ''
    patchShebangs ..
    substituteInPlace ../tools/mapping-tester/generate.py --replace '/bin/bash' '${pkgs.runtimeShell}'
    substituteInPlace ../tools/mapping-tester/generate.py --replace '/usr/bin/time' '${pkgs.time}/bin/time'
  '';

  meta = {
    description = "Artificial Solver Testing Environment";
    homepage = "https://github.com/precice/aste";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    platforms = lib.platforms.unix;
  };
}
