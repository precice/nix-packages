{ lib
, stdenv
, fetchFromGitHub
, fetchzip
, gcc
, pkg-config
, arpack
, lapack
, blas
, spooles
, libyamlcpp
, precice
, openmpi
}:
let
  ccx_version = "2.20";
  ccx = fetchzip {
    urls = [
      "https://www.dhondt.de/ccx_2.20.src.tar.bz2"
      "https://web.archive.org/web/20240302101853if_/https://www.dhondt.de/ccx_2.20.src.tar.bz2"
    ];
    hash = "sha256-bCmG+rcQDJrcwDci/WOAgjfbhy1vxdD+wnwRlt/ovKo=";
  };
in
stdenv.mkDerivation rec {
  pname = "calculix-adapter";
  version = "${ccx_version}.0";

  src = fetchFromGitHub {
    owner = "precice";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zyJ9VOpmjyBeettPWA3bFZIfyJuvs5D1nMxRcP5ySRY=";
  };

  nativeBuildInputs = [ gcc pkg-config arpack lapack blas spooles libyamlcpp precice openmpi ];

  buildPhase = ''
    mpifort --version
    make -j \
      CCX=${ccx}/ccx_2.20/src \
      SPOOLES_INCLUDE="-I${spooles}/include/spooles/" \
      ARPACK_INCLUDE="$(${pkg-config}/bin/pkg-config --cflags-only-I arpack lapack blas)" \
      ARPACK_LIBS="$(${pkg-config}/bin/pkg-config --libs arpack lapack blas)" \
      YAML_INCLUDE="$(${pkg-config}/bin/pkg-config --cflags-only-I yaml-cpp)" \
      YAML_LIBS="$(${pkg-config}/bin/pkg-config --libs yaml-cpp)" \
      ADDITIONAL_FFLAGS=-fallow-argument-mismatch
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}

    cp bin/ccx_preCICE $out/bin
    cp bin/ccx_2.20.a $out/lib
  '';

  meta = {
    description = "preCICE-adapter for the CSM code CalculiX";
    homepage = "https://precice.org/adapter-calculix-overview.html";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    mainProgram = "ccx_preCICE";
    platforms = lib.platforms.unix;
  };
}
