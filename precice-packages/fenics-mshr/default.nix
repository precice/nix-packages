{
  lib,
  stdenv,
  fetchFromBitbucket,
  python3,
  eigen,
  cgal,
  gmp,
  mpfr,
  boost,
  cmake,
  fenics,
  pkg-config,
  petsc,
}:
let
  mshr = stdenv.mkDerivation rec {
    name = "mshr";
    inherit (fenics) version;
    src = fetchFromBitbucket {
      owner = "fenics-project";
      repo = "mshr";
      rev = version;
      hash = "sha256-wgjdoV4uuuOYIShEBrSyTYPtf64XhrFVA2BF5t1eB0s=";
    };

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      boost
      gmp
      mpfr
      cgal
      eigen
      fenics.dolfin
      petsc
    ];

    enableParallelBuilding = true;
  };
in
python3.pkgs.buildPythonPackage {
  pname = "mshr";
  inherit (fenics) version;
  src = "${mshr.src}/python";

  nativeBuildInputs = [
    python3.pkgs.pybind11
    cmake
  ];
  buildInputs = [
    boost
    gmp
    mpfr
    cgal
    eigen
    fenics.dolfin
  ];
  dontUseCmakeConfigure = true;

  propagatedBuildInputs = [
    fenics
    python3.pkgs.numpy
    mshr
  ];

  doCheck = false;

  meta = {
    description = "mshr is the mesh generation component of FEniCS. It generates simplicial DOLFIN meshes in 2D and 3D from geometries described by Constructive Solid Geometry (CSG) or from surface files, utilizing CGAL and Tetgen as mesh generation backends.";
    homepage = "https://bitbucket.org/fenics-project/mshr";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
