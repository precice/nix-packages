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

    meta = {
      description = "FIAT: FInite element Automatic Tabulator";
      homepage = "https://github.com/FEniCS/fiat";
      license = with lib.licenses; [ lgpl3Only gpl3Only ];
      maintainers = with lib.maintainers; [ conni2461 ];
      platforms = lib.platforms.unix;
    };
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

    meta = {
      description = "A Python module for distributed just-in-time shared library building";
      homepage = "https://bitbucket.org/fenics-project/dijitso";
      license = with lib.licenses; [ lgpl3Only gpl3Only ];
      maintainers = with lib.maintainers; [ conni2461 ];
      platforms = lib.platforms.unix;
    };
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

    meta = {
      description = "UFL - Unified Form Language";
      longDescription = ''
        The Unified Form Language (UFL) is a domain specific language for
        declaration of finite element discretizations of variational forms.
        More precisely, it defines a flexible interface for choosing finite
        element spaces and defining expressions for weak forms in a notation
        close to mathematical notation.
      '';
      homepage = "https://github.com/FEniCS/ufl";
      license = with lib.licenses; [ lgpl3Only gpl3Only ];
      maintainers = with lib.maintainers; [ conni2461 ];
      platforms = lib.platforms.unix;
    };
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

    meta = {
      description = "FFC: The FEniCS Form Compiler";
      longDescription = ''
        FFC is a compiler for finite element variational forms. From a
        high-level description of the form, it generates efficient low-level
        C++ code that can be used to assemble the corresponding discrete
        operator (tensor). In particular, a bilinear form may be assembled into
        a matrix and a linear form may be assembled into a vector. FFC may be
        used either from the command line (by invoking the ffc command) or as a
        Python module (import ffc).
      '';
      homepage = "https://bitbucket.org/fenics-project/ffc";
      license = with lib.licenses; [ lgpl3Only gpl3Only ];
      maintainers = with lib.maintainers; [ conni2461 ];
      platforms = lib.platforms.unix;
    };
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
      # hdf5-mpi TODO: want this but its too new
      zlib
    ];

    doCheck = false;

    meta = {
      description = "DOLFIN is the computational backend of FEniCS and implements the FEniCS Problem Solving Environment in Python and C++.";
      homepage = "https://bitbucket.org/fenics-project/dolfin";
      license = with lib.licenses; [ lgpl3Only gpl3Only ];
      maintainers = with lib.maintainers; [ conni2461 ];
      platforms = lib.platforms.unix;
    };
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

  meta = {
    description = "DOLFIN is the computational backend of FEniCS and implements the FEniCS Problem Solving Environment in Python and C++.";
    homepage = "https://bitbucket.org/fenics-project/dolfin";
    license = with lib.licenses; [ lgpl3Only gpl3Only ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
