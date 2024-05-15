{
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
}
