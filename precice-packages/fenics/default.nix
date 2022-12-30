{ lib
, stdenv
, fetchFromGitHub
, fetchFromBitbucket
, python3
, cmake
, ninja
, gcc
, boost172
, eigen
, pkg-config
, petsc
, petsc4py
, openmpi
, openssh
, blas
, zlib
}:
let
  version = "2019.1.0";
  fiat = python3.pkgs.buildPythonPackage rec {
    pname = "fiat";
    inherit version;

    src = fetchFromGitHub {
      owner = "FEniCS";
      repo = pname;
      rev = version;
      hash = "sha256-IpHdtJqT/KBLbF0f4d5cNrseEjD9cVko+Q+cEr073gU=";
    };

    propagatedBuildInputs = with python3.pkgs; [ numpy sympy ];

    doCheck = false;
  };
  dijitso = python3.pkgs.buildPythonPackage rec {
    pname = "dijitso";
    inherit version;

    src = fetchFromBitbucket {
      owner = "fenics-project";
      repo = pname;
      rev = version;
      hash = "sha256-1y19nznH0p0i2PA5rkp5xKQsySyEJ9vRMfJreClqznE=";
    };

    propagatedBuildInputs = with python3.pkgs; [ numpy ];

    doCheck = false;
  };
  ufl = python3.pkgs.buildPythonPackage rec {
    pname = "ufl";
    inherit version;

    src = fetchFromGitHub {
      owner = "FEniCS";
      repo = pname;
      rev = version;
      hash = "sha256-UPwTU6biFhnOOhrxaTPhgWKwHjGSnaKgPHZ0+JBPmKc=";
    };

    propagatedBuildInputs = with python3.pkgs; [ numpy ];

    doCheck = false;
  };
  ffc = python3.pkgs.buildPythonPackage rec {
    pname = "ffc";
    inherit version;

    src = fetchFromBitbucket {
      owner = "fenics-project";
      repo = pname;
      rev = version;
      hash = "sha256-zEDGT0SlZFk8bdFtXRhCvcKKoL3Xdq2UyE8JrMPkIoU=";
    };

    propagatedBuildInputs = [ fiat dijitso ufl ];

    doCheck = false;
  };
  dolfin_src = fetchFromBitbucket {
    owner = "fenics-project";
    repo = "dolfin";
    rev = version;
    hash = "sha256-Xa0d/UaDqt1OihUJBKxe51ckSwVkVpggeOBq1L045X8=";
  };
  dolfin_cxx = stdenv.mkDerivation rec {
    pname = "dolfin";
    inherit version;

    src = dolfin_src;

    patches = [
      ./cxx17.diff
      ./fix_petsc_build.diff
    ];

    cmakeFlags = [
      # the cmake package does not handle absolute CMAKE_INSTALL_INCLUDEDIR correctly
      # (setting it to an absolute path causes include files to go to $out/$out/include,
      #  because the absolute path is interpreted with root at $out).
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"
      # TODO fixme
      "-DDOLFIN_SKIP_BUILD_TESTS=1"
    ];

    nativeBuildInputs = [
      cmake
      ninja
      gcc
      boost172
      eigen
      pkg-config

      python3
      python3.pkgs.setuptools
      ffc

      # optional packages
      openmpi
      blas
      petsc
      # hdf5-mpi is too new
      zlib
    ];

    doCheck = false;
  };
in
python3.pkgs.buildPythonPackage rec {
  pname = "fenics";
  inherit version;

  src = "${dolfin_src}/python";

  patches = [
    ./fix_pybind11.diff
  ];

  nativeBuildInputs = [
    cmake
    ninja
    openmpi
    openssh
    pkg-config
  ];
  propagatedBuildInputs = [
    python3.pkgs.numpy
    python3.pkgs.pkgconfig
    python3.pkgs.mpi4py
    python3.pkgs.pybind11
    python3.pkgs.setuptools
    petsc4py

    fiat
    dijitso
    ufl
    ffc
    dolfin_cxx

    boost172
    petsc
  ];

  dontUseCmakeConfigure = true;
}
