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
  python = python3.withPackages (ps: with ps; [
    numpy
    sympy
    scipy
  ]);

  python_vtk_9 = python3.pkgs.toPythonModule (vtk_9.override {
    inherit python;
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
    hash = "sha256-hYqpM59NJGIOefMBFS2zd39lQyGoyU0ypJVdCzSsGT8=";
  };

  nativeBuildInputs = [
    cmake
    gcc
    libGL
    libX11
    precice
  ];
  buildInputs = [
    boost
    metis
    openmpi
  ];
  propagatedBuildInputs = [
    python
    python_vtk_9
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
