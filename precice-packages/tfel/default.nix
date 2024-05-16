{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  cmake,
  gfortran,
  python3,
  boost,
}:
stdenv.mkDerivation rec {
  pname = "tfel";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "thelfer";
    repo = pname;
    rev = "TFEL-${version}";
    hash = "sha256-dUcjOOIwYFAJgCGXubTgzNUn0Ti56J630X21VObv6mQ=";
  };

  nativeBuildInputs = [
    gcc
    gfortran
    cmake
    python3
    boost
    python3.pkgs.boost
  ];

  cmakeFlags = [
    "-DTFEL_SVN_REVISION=${version}"
    "-DTFEL_APPEND_VERSION=${version}"

    "-DCMAKE_Fortran_COMPILER=gfortran"
    "-Dlocal-castem-header=ON"
    "-Denable-fortran=OFF"

    "-Denable-broken-boost-python-module-visibility-handling=ON"
    "-Denable-python-bindings=ON"
    "-Denable-cyrano=ON"
    "-Denable-aster=ON"
    "-Denable-portable-build=OFF"
    "-Denable-python=ON"

    "-Ddisable-reference-doc=ON"
    "-Ddisable-website=ON"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "MFront is a code generator which translates a set of closely related domain specific languages into plain C++ on top of the TFEL library.";
    homepage = "https://thelfer.github.io/tfel/web/";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
