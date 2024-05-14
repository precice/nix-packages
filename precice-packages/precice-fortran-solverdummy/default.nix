{
  stdenv,
  gfortran,
  pkg-config,
  precice,
  precice-fortran-module,
  ...
}:
stdenv.mkDerivation rec {
  name = "precice-fortran-solverdummy";

  inherit (precice-fortran-module) src;

  nativeBuildInputs = [
    gfortran
    pkg-config
    precice
  ];

  buildPhase = ''
    pushd examples/solverdummy
    gfortran solverdummy.f03 -I${precice-fortran-module}/lib/ -L$(pkg-config --libs libprecice) -o ${name}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${name} $out/bin/
  '';
}
