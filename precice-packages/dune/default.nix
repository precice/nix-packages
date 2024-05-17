{
  lib,
  stdenv,
  symlinkJoin,
  fetchFromGitLab,
  fetchFromGitHub,
  gcc,
  cmake,
  ninja,
  pkg-config,
  blas,
  lapack,
  arpack,
  openmpi,
  python3,
  metis,
  parmetis,
  vc,
  gmp,
  precice,
  llvmPackages,
  petsc,
  suitesparse,
  fenics,
}:
let
  version = "2.8.0";
  dune_common_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "core";
    repo = "dune-common";
    rev = "v${version}";
    hash = "sha256-pIpeev+cc9UnQHpM4OokbAeI/hSgOb7p9NVNgVCXmYI=";
  };
  dune_istl_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "core";
    repo = "dune-istl";
    rev = "v${version}";
    hash = "sha256-d69xi8Z9IG6uptooiDSM/bLEwbqnGhM02U7XTH6RNgc=";
  };
  dune_localfunctions_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "core";
    repo = "dune-localfunctions";
    rev = "v${version}";
    hash = "sha256-pfXy4OzCkE+6WBVT1Kf7kjjArFfhIFWjb23YUlxJxvw=";
  };
  dune_grid_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "core";
    repo = "dune-grid";
    rev = "v${version}";
    hash = "sha256-vojYV5ZDnJ1BYX3W4eTI4EY3QNLyObLQcdgUOCjhDCI=";
  };
  dune_geometry_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "core";
    repo = "dune-geometry";
    rev = "v${version}";
    hash = "sha256-BPseYFfx1Nvz0RK3VPAY96lw6HLfpb8aq10BkPxMqz8=";
  };
  dune_functions_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "staging";
    repo = "dune-functions";
    rev = "v${version}";
    hash = "sha256-fs3qPo18uhngBrZdPUT+cXGgY4tj+fhNLC8s/6QWga4=";
  };
  dune_uggrid_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "staging";
    repo = "dune-uggrid";
    rev = "v${version}";
    hash = "sha256-Pb+h1MwrS+zKY9V9ZenUKdi+byW0oWAyyCGeZibIXSQ=";
  };
  dune_typetree_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "staging";
    repo = "dune-typetree";
    rev = "v${version}";
    hash = "sha256-/XqtCL3pgCgdyLroEDeed/zC38jnZCmEB6iIQVTanNU=";
  };
  dune_alugrid_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "extensions";
    repo = "dune-alugrid";
    rev = "v${version}";
    hash = "sha256-qlAOWicJk77yzpMMratNuk/nSO/jp1yKS5H7sBEcpqI=";
  };
  dune_foamgrid_src = fetchFromGitLab {
    domain = "gitlab.dune-project.org";
    owner = "extensions";
    repo = "dune-foamgrid";
    rev = version;
    hash = "sha256-+wOUugrhPWPht//gS5M29b4PvdvZTBUp7PYyFcYNDE4=";
  };
  dune_elastodynamics_src = fetchFromGitHub {
    owner = "maxfirmbach";
    repo = "dune-elastodynamics";
    rev = "40896b13e2c490921513c7ffe8a9a64026026399";
    hash = "sha256-VoaDS+WVX6lPHXO4Eaft3qPumuUR1Rg3PBG6sVik8no=";
  };
  dune_adapter_src = fetchFromGitHub {
    owner = "precice";
    repo = "dune-adapter";
    rev = "5f2364d57b517698914cb1d5f9979efe692d9254";
    hash = "sha256-fsYyc2DzK4AJJbXo5doX+QopKVfoNLpBKb1rfbUDgyc=";
  };
  dune = python3.pkgs.toPythonModule (
    stdenv.mkDerivation {
      pname = "dune";
      inherit version;

      unpackPhase = ''
        runHook preUnpack

        cp -r ${dune_common_src} dune-common
        cp -r ${dune_istl_src} dune-istl
        cp -r ${dune_localfunctions_src} dune-localfunctions
        cp -r ${dune_grid_src} dune-grid
        cp -r ${dune_geometry_src} dune-geometry
        cp -r ${dune_functions_src} dune-functions
        cp -r ${dune_uggrid_src} dune-uggrid
        cp -r ${dune_typetree_src} dune-typetree
        cp -r ${dune_alugrid_src} dune-alugrid
        cp -r ${dune_foamgrid_src} dune-foamgrid
        cp -r ${dune_elastodynamics_src} dune-elastodynamics
        cp -r ${dune_adapter_src} dune-adapter

        chmod -R +w .

        runHook postUnpack
      '';

      patches = [
        ./0001-no-upgrade.patch
        ./0002-no-dune-configure.patch
      ];

      nativeBuildInputs = [
        gcc
        cmake
        ninja
        pkg-config
        blas
        lapack
        arpack
        openmpi
        python3
        metis
        parmetis
        vc
        gmp
        precice
        llvmPackages.openmp
        petsc
        suitesparse
      ];
      propagatedBuildInputs = [
        python3.pkgs.pip
        python3.pkgs.setuptools
        python3.pkgs.virtualenv
        python3.pkgs.wheel
        python3.pkgs.scikit-build
        python3.pkgs.requests
        python3.pkgs.portalocker
        python3.pkgs.numpy
        python3.pkgs.mpi4py
        fenics

        # Not great but we need these at runtime
        pkg-config
        cmake
        metis
        parmetis
      ];

      configurePhase = ''
        runHook preConfigure

        patchShebangs .

        # PATH needs to be empty
        export DUNE_CONTROL_PATH=
        export DUNE_PY_DIR=$PWD/.cache/dune-py
        mkdir -p $DUNE_PY_DIR

        export CMAKE_FLAGS=" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$out \
          -DDUNE_GRID_GRIDTYPE_SELECTOR=ON \
          -DCMAKE_DISABLE_FIND_PACKAGE_ParMETIS=ON \
          -DDUNE_GRID_EXPERIMENTAL_GRID_EXTENSIONS=ON \
          -DDUNE_PYTHON_INSTALL_LOCATION=\"system\" \
          -DDUNE_ENABLE_PYTHONBINDINGS=ON \
          -DBUILD_SHARED_LIBS=TRUE \
          -DDUNE_PYTHON_ADDITIONAL_PIP_PARAMS=\"--prefix=$out\" \
        "

        ./dune-common/bin/dunecontrol cmake

        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild

        ./dune-common/bin/dunecontrol make -j

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        ./dune-common/bin/dunecontrol make install
        ./dune-common/bin/dunecontrol make install_python

        # TODO: figure out why cmake isn't linking correctly and we need to patchelf
        patchelf --set-rpath "$out/lib64:$(patchelf --print-rpath $out/${python3.sitePackages}/dune/common/_common.so)" $out/${python3.sitePackages}/dune/common/_common.so
        patchelf --set-rpath "$out/lib64:$(patchelf --print-rpath $out/${python3.sitePackages}/dune/geometry/_geometry.so)" $out/${python3.sitePackages}/dune/geometry/_geometry.so
        patchelf --set-rpath "$out/lib64:$(patchelf --print-rpath $out/${python3.sitePackages}/dune/istl/_istl.so)" $out/${python3.sitePackages}/dune/istl/_istl.so
        patchelf --set-rpath "$out/lib64:$(patchelf --print-rpath $out/${python3.sitePackages}/dune/localfunctions/_localfunctions.so)" $out/${python3.sitePackages}/dune/localfunctions/_localfunctions.so
        patchelf --set-rpath "$out/lib64:$(patchelf --print-rpath $out/${python3.sitePackages}/dune/grid/_grid.so)" $out/${python3.sitePackages}/dune/grid/_grid.so

        # This is the example adapter
        cp dune-adapter/dune-precice-howto/build-cmake/examples/dune-perpendicular-flap $out/bin
        patchelf --set-rpath "$out/lib64:$(patchelf --print-rpath $out/bin/dune-perpendicular-flap)" $out/bin/dune-perpendicular-flap

        runHook postInstall
      '';

      dontMoveLib64 = true;

      meta = {
        description = ''
          DUNE, the Distributed and Unified Numerics Environment is a modular
          toolbox for solving partial differential equations with grid-based
          methods.
        '';
        homepage = "https://www.dune-project.org/";
        license = with lib.licenses; [ gpl2 ];
        maintainers = with lib.maintainers; [ conni2461 ];
        platforms = lib.platforms.unix;
      };
    }
  );
  dune-fem = python3.pkgs.buildPythonPackage rec {
    pname = "dune-fem";
    version = "2.8.0";

    src = python3.pkgs.fetchPypi {
      inherit pname;
      version = "${version}.0";
      hash = "sha256-sug55x+DFoRRmJXTt/nK+yJQ2GYs4LHwjYjviZ1U8HI=";
    };

    preBuild = ''
      export DUNE_CONTROL_PATH=${dune}
      export DUNE_PY_DIR=$PWD/.cache/dune-py
    '';

    nativeBuildInputs = [
      cmake
      dune
      openmpi
      pkg-config
      fenics
    ];
    # Don't know why we need this
    propagatedBuildInputs = [
      metis
      parmetis
    ];
    dontUseCmakeConfigure = true;
    enableParallelBuilding = true;
    doCheck = false;
    dontMoveLib64 = true;

    meta = {
      description = ''
        DUNE-FEM is a Distributed and Unified Numerics Environment module which
        defines interfaces for implementing discretization methods like Finite
        Element Methods (FEM) and Finite Volume Methods (FV) and Discontinuous
        Galerkin Methods (DG).
      '';
      homepage = "https://gitlab.dune-project.org/dune-fem/dune-fem";
      license = with lib.licenses; [ gpl2 ];
      maintainers = with lib.maintainers; [ conni2461 ];
      platforms = lib.platforms.unix;
    };
  };
in
python3.pkgs.toPythonModule (symlinkJoin {
  name = "precice-dune";
  paths = [
    dune
    dune-fem
  ];
  postBuild = ''
    cat <<EOF > $out/bin/set-dune-vars
      export DUNE_CONTROL_PATH=$out
      export DUNE_PY_DIR=\$HOME/.cache/dune-py/${version}

      # we kinda wanna index this once and make sure this works
      python -c "from dune.grid import structuredGrid"
      python -c "from dune.fem import parameter"
    EOF
    chmod +x $out/bin/set-dune-vars
  '';
})
