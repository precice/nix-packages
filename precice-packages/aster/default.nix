{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  gcc,
  gfortran,
  cmake,
  tk,
  bison,
  flex,
  liblapack,
  zlib,
  glibc,
  python3,
  ps,
  hdf5_1_10,
  medfile,
  mumps,
  tfel,
  scotch,
  getopt,
  rsync,
}:
let
  hdf5_home = stdenvNoCC.mkDerivation {
    name = "hdf5_1_10";
    inherit (hdf5_1_10) version;

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out

      ln -s ${hdf5_1_10.dev}/include $out/include
      ln -s ${hdf5_1_10.out}/lib $out/lib
      ln -s ${hdf5_1_10.out}/bin $out/bin
    '';
  };
  adapter = fetchFromGitHub {
    owner = "precice";
    repo = "code_aster-adapter";
    rev = "ce995e0c41b26fe891ce04fd47fd52cbeff854e9";
    hash = "sha256-NByYVE4joct12XDBHjju2tcutxLyplKt+EPMtrTJ224=";
  };
in
stdenv.mkDerivation rec {
  pname = "aster";
  version = "14.6.0";

  src = fetchurl {
    url = "https://www.code-aster.org/FICHIERS/aster-full-src-${version}-1.noarch.tar.gz";
    hash = "sha256-3LOQDeHlwGJAYCU2YKY1EqtBXL4UPN2HhnoCdu9r8jM=";
  };

  patches = [ ./0001-fix-site-packages.patch ];

  nativeBuildInputs = [
    gcc
    gfortran
    cmake
    python3
    bison
    flex
    ps
    liblapack
    tk
    getopt
  ];

  buildPhase = # bash
    ''
      runHook preBuild

      # TODO: eval if this is still required
      export LD_LIBRARY_PATH="${gcc.cc.lib}/lib:${glibc.out}/lib:${zlib.out}/lib:${liblapack}/lib:${tk.out}/lib:${flex}/lib:$LD_LIBRARY_PATH"

      cat <<EOF >> setup.cfg
      _install_hdf5 = False
      HOME_HDF = "${hdf5_home}"

      _install_med = False
      HOME_MED = "${medfile}"

      _install_mumps = False
      HOME_MUMPS = "${mumps}"

      _install_tfel = False
      HOME_MFRONT = "${tfel}"

      _install_scotch = False
      HOME_SCOTCH = "${scotch}"

      ASTER_ROOT="$out"
      EOF

      tar -zxf SRC/aster-14.6.0.tgz
      patchShebangs .
      tar -czvf SRC/aster-14.6.0.tgz aster-14.6.0
      rm -rf aster-14.6.0

      tar -zxf SRC/metis-5.1.0-aster4.tar.gz
      sed -i '3d' metis-5.1.0/programs/CMakeLists.txt
      tar -czvf SRC/metis-5.1.0-aster4.tar.gz metis-5.1.0
      rm -rf metis-5.1.0

      ${python3.interpreter} setup.py install --prefix=$out --noprompt

      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall

    ${rsync}/bin/rsync -av $out/14.6/* $out
    rm -rf $out/14.6

    mkdir -v $out/14.6
    ln -s $out/* $out/14.6/
    ln -s $out/share/aster/* $out/14.6/

    ln -s $out/14.6 $out/stable

    cp ${adapter}/cht/adapter.py $out/lib/aster/Execution
    cp ${adapter}/cht/adapter.comm $out/share/

    # DELETE tests to save space
    rm -rfv $out/share/aster/tests

    runHook postInstall
  '';

  propagatedBuildInputs = [
    python3.pkgs.numpy
    python3.pkgs.boost
  ];

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;

  meta = {
    description = "Structures and Thermomechanics Analysis for Studies and Research";
    homepage = "https://code-aster.org";
    license = with lib.licenses; [ gpl2 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
