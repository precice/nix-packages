{
  lib,
  stdenv,
  fetchurl,
  fetchpatch2,
  blas,
  boost,
  cmake,
  doxygen,
  eigen,
  hdf5_1_10,
  lapack,
  mpi,
  pkg-config,
  python3,
  scotch,
  sphinx,
  suitesparse,
  swig,
  zlib,
  nixosTests,
  petsc,
  petsc4py,
  metis,
  parmetis,
}:

let
  version = "2019.1.0";

  dijitso = python3.pkgs.buildPythonPackage {
    pname = "dijitso";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/dijitso/downloads/dijitso-${version}.tar.gz";
      sha256 = "1ncgbr0bn5cvv16f13g722a0ipw6p9y6p4iasxjziwsp8kn5x97a";
    };
    propagatedBuildInputs = [
      python3.pkgs.numpy
      python3.pkgs.six
    ];
    nativeCheckInputs = [ python3.pkgs.pytest ];
    preCheck = ''
      export HOME=$PWD
    '';
    checkPhase = ''
      runHook preCheck
      py.test test/
      runHook postCheck
    '';
    meta = {
      description = "Distributed just-in-time shared library building";
      homepage = "https://fenicsproject.org/";
      platforms = lib.platforms.all;
      license = lib.licenses.lgpl3;
    };
  };

  fiat = python3.pkgs.buildPythonPackage {
    pname = "fiat";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/fiat/downloads/fiat-${version}.tar.gz";
      sha256 = "1sbi0fbr7w9g9ajr565g3njxrc3qydqjy3334vmz5xg0rd3106il";
    };
    propagatedBuildInputs = [
      python3.pkgs.numpy
      python3.pkgs.six
      python3.pkgs.sympy
    ];
    nativeCheckInputs = [ python3.pkgs.pytest ];

    preCheck = ''
      # Workaround pytest 4.6.3 issue.
      # See: https://bitbucket.org/fenics-project/fiat/pull-requests/59
      rm test/unit/test_quadrature.py
      rm test/unit/test_reference_element.py
      rm test/unit/test_fiat.py

      # Fix `np.float` deprecation in Numpy 1.20
      grep -lr 'np.float(' test/ | while read -r fn; do
        substituteInPlace "$fn" \
          --replace "np.float(" "np.float64("
      done
    '';
    checkPhase = ''
      runHook preCheck
      py.test test/unit/
      runHook postCheck
    '';
    meta = {
      description = "Automatic generation of finite element basis functions";
      homepage = "https://fenicsproject.org/";
      platforms = lib.platforms.all;
      license = lib.licenses.lgpl3;
    };
  };

  ufl = python3.pkgs.buildPythonPackage {
    pname = "ufl";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/ufl/downloads/ufl-${version}.tar.gz";
      sha256 = "04daxwg4y9c51sdgvwgmlc82nn0fjw7i2vzs15ckdc7dlazmcfi1";
    };
    propagatedBuildInputs = [
      python3.pkgs.numpy
      python3.pkgs.six
    ];
    nativeCheckInputs = [ python3.pkgs.pytest ];
    checkPhase = ''
      runHook preCheck
      py.test test/
      runHook postCheck
    '';
    meta = {
      description = "A domain-specific language for finite element variational forms";
      homepage = "https://fenicsproject.org/";
      platforms = lib.platforms.all;
      license = lib.licenses.lgpl3;
    };
  };

  ffc = python3.pkgs.buildPythonPackage {
    pname = "ffc";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/ffc/downloads/ffc-${version}.tar.gz";
      sha256 = "1zdg6pziss4va74pd7jjl8sc3ya2gmhpypccmyd8p7c66ji23y2g";
    };
    nativeBuildInputs = [ python3.pkgs.pybind11 ];
    propagatedBuildInputs = [
      dijitso
      fiat
      python3.pkgs.numpy
      python3.pkgs.six
      python3.pkgs.sympy
      ufl
      python3.pkgs.setuptools
    ];
    nativeCheckInputs = [ python3.pkgs.pytest ];
    preCheck = ''
      export HOME=$PWD
      rm test/unit/ufc/finite_element/test_evaluate.py
    '';
    checkPhase = ''
      runHook preCheck
      py.test test/unit/
      runHook postCheck
    '';
    meta = {
      description = "A compiler for finite element variational forms";
      homepage = "https://fenicsproject.org/";
      platforms = lib.platforms.all;
      license = lib.licenses.lgpl3;
    };
  };
  dolfin = stdenv.mkDerivation {
    pname = "dolfin";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/dolfin/downloads/dolfin-${version}.tar.gz";
      sha256 = "0kbyi4x5f6j4zpasch0swh0ch81w2h92rqm1nfp3ydi4a93vky33";
    };
    patches = [
      (fetchpatch2 {
        name = "fix-double-prefix.patch";
        url = "https://bitbucket.org/josef_kemetmueller/dolfin/commits/328e94acd426ebaf2243c072b806be3379fd4340/raw";
        sha256 = "1zj7k3y7vsx0hz3gwwlxhq6gdqamqpcw90d4ishwx5ps5ckcsb9r";
      })
      (fetchpatch2 {
        url = "https://bitbucket.org/fenics-project/dolfin/issues/attachments/1116/fenics-project/dolfin/1602778118.04/1116/0001-Use-__BYTE_ORDER__-instead-of-removed-Boost-endian.h.patch";
        hash = "sha256-wPaDmPU+jaD3ce3nNEbvM5p8e3zBdLozamLTJ/0ai2c=";
      })
      # fixing petsc
      (fetchpatch2 {
        url = "https://bitbucket.org/fenics-project/dolfin/commits/57bb03fe018506d05f795f44a73e94b15821b9a4/raw";
        hash = "sha256-K/HNGgMOg0bv/Fm/dI1bt/LaZx4kuK1fo8m1kvtPknU=";
      })
      (fetchpatch2 {
        url = "https://bitbucket.org/fenics-project/dolfin/commits/74d7efe1e84d65e9433fd96c50f1d278fa3e3f3f/raw";
        hash = "sha256-KEf0ESKpmAUSh2UY8usYV1u6QrfkIcCn7hCeafGF+ds=";
      })
    ];
    # https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=dolfin&id=a965ad934f7b3d49a5e77fa6fb5e3c710ec2163e
    postPatch = ''
      sed -i '20 a #include <algorithm>' dolfin/geometry/IntersectionConstruction.cpp
      sed -i '26 a #include <algorithm>' dolfin/mesh/MeshFunction.h
      sed -i '25 a #include <cstdint>' dolfin/mesh/MeshConnectivity.h
    '';
    propagatedBuildInputs = [
      dijitso
      fiat
      python3.pkgs.numpy
      python3.pkgs.six
      ufl
    ];
    nativeBuildInputs = [
      cmake
      doxygen
      pkg-config
    ];
    buildInputs = [
      boost
      dijitso
      eigen
      ffc
      fiat
      hdf5_1_10
      mpi
      python3.pkgs.numpy
      blas
      lapack
      python3.pkgs.ply
      python3
      scotch
      python3.pkgs.six
      sphinx
      suitesparse
      swig
      python3.pkgs.sympy
      ufl
      zlib

      # optional
      petsc
      petsc4py
      metis
      parmetis
    ];
    cmakeFlags = [
      "-DDOLFIN_CXX_FLAGS=-std=c++11"
      "-DDOLFIN_AUTO_DETECT_MPI=ON"
      "-DDOLFIN_ENABLE_CHOLMOD=ON"
      "-DDOLFIN_ENABLE_DOCS=ON"
      "-DDOLFIN_ENABLE_HDF5=ON"
      "-DDOLFIN_ENABLE_MPI=ON"
      "-DDOLFIN_ENABLE_SCOTCH=ON"
      "-DDOLFIN_ENABLE_UMFPACK=ON"
      "-DDOLFIN_ENABLE_ZLIB=ON"
      "-DDOLFIN_SKIP_BUILD_TESTS=ON" # Otherwise SCOTCH is not found
      "-DDOLFIN_ENABLE_PARMETIS=ON"
      "-DDOLFIN_ENABLE_PETSC=ON"
      # TODO: Enable the following features
      "-DDOLFIN_ENABLE_SLEPC=OFF"
      "-DDOLFIN_ENABLE_TRILINOS=OFF"
    ];
    installCheckPhase = ''
      source $out/share/dolfin/dolfin.conf
      make runtests
    '';
    meta = {
      description = "The FEniCS Problem Solving Environment in Python and C++";
      homepage = "https://fenicsproject.org/";
      license = lib.licenses.lgpl3;
    };
  };
  python-dolfin = python3.pkgs.buildPythonPackage rec {
    pname = "dolfin";
    inherit version;
    disabled = python3.pkgs.isPy27;
    inherit (dolfin) src;
    sourceRoot = "${pname}-${version}/python";
    nativeBuildInputs = [
      python3.pkgs.pybind11
      cmake
      pkg-config
    ];
    dontUseCmakeConfigure = true;
    preConfigure = ''
      export CMAKE_PREFIX_PATH=${python3.pkgs.pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
      substituteInPlace setup.py --replace "pybind11==2.2.4" "pybind11"
      substituteInPlace dolfin/jit/jit.py \
        --replace 'pkgconfig.exists("dolfin")' 'pkgconfig.exists("${dolfin}/lib/pkgconfig/dolfin.pc")' \
        --replace 'pkgconfig.parse("dolfin")' 'pkgconfig.parse("${dolfin}/lib/pkgconfig/dolfin.pc")'
    '';
    buildInputs = [
      dolfin
      boost
      petsc
    ];

    propagatedBuildInputs = [
      dijitso
      ffc
      python3.pkgs.mpi4py
      python3.pkgs.numpy
      ufl
      python3.pkgs.pkgconfig
      python3.pkgs.pybind11
      petsc4py
    ];
    doCheck = false; # Tries to orte_ess_init and call ssh to localhost
    passthru = {
      tests = {
        inherit (nixosTests) fenics;
      };
      inherit dolfin;
    };
    meta = {
      description = "Python bindings for the DOLFIN FEM compiler";
      homepage = "https://fenicsproject.org/";
      platforms = lib.platforms.all;
      license = lib.licenses.lgpl3;
    };
  };
in
python-dolfin
