{ lib
, stdenv
, fetchFromGitHub
, cmake
, gcc
, openmpi
, boost # dont use bundled boost
, adolc
, arpack
, assimp
, liblapack
, cgal_5, gmp, mpfr
, gmsh
, gsl
, scalapack
, blacs
, metis
, hdf5-mpi
, p4est
, petsc
, zlib
, openssh
}:

stdenv.mkDerivation rec {
  pname = "dealii";
  version = "9.4.1";

  src = fetchFromGitHub {
    owner = "dealii";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Kz78U5ud36cTMq4E8FclOsmNsjMZfz+23tRXW/sl498=";
  };

  # we need to limit build cores because otherwise dealii needs to much memory
  # and garnix runs in an out of memory issue
  preConfigure = ''
    if (( $NIX_BUILD_CORES > 8)); then
      export NIX_BUILD_CORES=8
    fi
  '';

  nativeBuildInputs = [
    cmake
    gcc
    openmpi
    boost
    adolc
    arpack
    assimp
    liblapack
    cgal_5 gmp mpfr # for cgal gmp and mpfr are also required
    gmsh
    gsl
    scalapack blacs # both are needed
    metis
    hdf5-mpi
    p4est
    petsc
    zlib
  ];

  cmakeFlags = [
    "-DDEAL_II_WITH_MPI=ON"
    "-DDEAL_II_HAVE_CXX17=ON"
  ];

  doCheck = true;

  nativeCheckInputs = [ openssh ];

  meta = {
    description = "An open source finite element library";
    homepage = "https://www.dealii.org/";
    license = with lib.licenses; [ lgpl21Only ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    platforms = lib.platforms.unix;
  };
}
