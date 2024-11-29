{
  lib,
  stdenv,
  fetchgit,
  gnumake,
  openmpi,
  m4,
  zlib,
  flex,
  makeWrapper,
  writeScript,
  version,
  hash,
  scotch,
}:

let
  # TODO: Can we make the last export to /run/current-system better somehow?
  set-vars-script = writeScript "set-openfoam-vars" ''
    export FOAM_API=${version}
    export WM_PROJECT=OpenFOAM
    export WM_PROJECT_VERSION=v${version}
    export FOAM_MPI=sys-openmpi
    export WM_MPLIB=SYSTEMOPENMPI

    export BUILD_PLATFORM=linux
    export WM_COMPILER=Gcc
    export WM_COMPILER_LIB_ARCH=64
    export WM_COMPILER_TYPE=system
    export WM_COMPILE_OPTION=Opt
    export WM_LABEL_OPTION=Int32
    export WM_LABEL_SIZE=32
    export WM_PRECISION_OPTION=DP

    export WM_ARCH=$BUILD_PLATFORM$WM_COMPILER_LIB_ARCH
    export WM_OPTIONS=$WM_ARCH$WM_COMPILER$WM_PRECISION_OPTION$WM_LABEL_OPTION$WM_COMPILE_OPTION

    export OPENFOAM_SRC_PATH=/build/openfoam

    export WM_PROJECT_DIR=$OPENFOAM_SRC_PATH

    export FOAM_APP=$OPENFOAM_SRC_PATH/applications
    export FOAM_ETC=$OPENFOAM_SRC_PATH/etc
    export FOAM_SRC=$OPENFOAM_SRC_PATH/src

    export FOAM_SOLVERS=$FOAM_APP/solvers
    export FOAM_UTILITIES=$FOAM_APP/utilities

    export FOAM_APPBIN=$OPENFOAM_SRC_PATH/platforms/$WM_OPTIONS/bin
    export FOAM_LIBBIN=$OPENFOAM_SRC_PATH/platforms/$WM_OPTIONS/lib

    export FOAM_USER_LIBBIN=/tmp/OpenFOAM/lib
    export FOAM_USER_APPBIN=/tmp/OpenFOAM/bin

    export WM_THIRD_PARTY_DIR=$OPENFOAM_SRC_PATH/ThirdParty
    export FOAM_TUTORIALS=$OPENFOAM_SRC_PATH/tutorials

    export WM_DIR=$OPENFOAM_SRC_PATH/wmake

    export PATH=$WM_DIR:$PATH
    export PATH=$FOAM_APPBIN:$PATH

    export WM_NCOMPPROCS=$NIX_BUILD_CORES

    export LD_LIBRARY_PATH=$OPENFOAM_SRC_PATH/src/OpenFOAM/lnInclude:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$FOAM_LIBBIN:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$FOAM_LIBBIN/dummy:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=/run/current-system/sw/lib/:$LD_LIBRARY_PATH

    export SCOTCH_VERSION=scotch_${scotch.version}
    export SCOTCH_ARCH_PATH=${scotch}
  '';
in
stdenv.mkDerivation rec {
  pname = "openfoam";
  inherit version;

  src = fetchgit {
    url = "https://develop.openfoam.com/Development/openfoam.git";
    rev = "OpenFOAM-v${version}";
    inherit hash;
  };

  nativeBuildInputs = [
    gnumake
    m4
    makeWrapper
  ];
  buildInputs = [
    openmpi
    zlib
    flex
    scotch
  ];

  postPatch = ''
    patchShebangs --build wmake/scripts/wrap-lemon
    patchShebangs --build wmake/wmake
    patchShebangs --build wmake/wmakeCollect
    patchShebangs --build wmake/wmakeLnIncludeAll
  '';

  buildPhase = ''
    cat <<EOF > etc/config.sh/scotch
    export SCOTCH_VERSION=scotch_${scotch.version}
    export SCOTCH_ARCH_PATH=${scotch}
    EOF

    cp ${set-vars-script} bin/set-openfoam-vars
    source bin/set-openfoam-vars

    ./Allwmake -j -q
  '';

  installPhase = ''
    mkdir -p $out

    cp -r ./META-INFO $out/
    cp -r ./applications $out/
    cp -r ./bin $out/
    cp -r ./etc $out/
    cp -r ./modules $out/
    cp -r ./platforms $out/
    cp -r ./src $out/
    cp -r ./tutorials $out/
    cp -r ./wmake $out/

    sed -i "s^/build/openfoam^$out^" $out/bin/set-openfoam-vars

    makeWrapper $out/etc/openfoam $out/bin/openfoam
    ln -s $out/bin/openfoam $out/bin/openfoam${version}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    source $out/bin/set-openfoam-vars
    $out/bin/foamInstallationTest
    $out/bin/foamInstallationTest -full incompressible/simpleFoam/pitzDaily
  '';

  meta = {
    description = "OpenFOAM free, open source CFD software";
    homepage = "https://www.openfoam.com/";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    platforms = lib.platforms.unix;
  };
}
