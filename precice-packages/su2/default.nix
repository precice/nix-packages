{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, gcc
, python3
, pkg-config
, precice
, makeWrapper
, enableMPI ? false
, openmpi
, enableCgns ? false
, enableDOT ? false
, enableMSH ? false
, enableDEF ? false
, enableSOL ? false
, enableGEO ? false
}:
let
  version = "6.0.0";
  su2_src = fetchFromGitHub {
    owner = "su2code";
    repo = "su2";
    rev = "v${version}";
    hash = "sha256-3zIqzrmOTueTi+BmWwNnExO05J5tfENDMaXwr6l0v7Y=";
  };
  adapter_src = fetchFromGitHub {
    owner = "precice";
    repo = "su2-adapter";
    rev = "ab843878c1d43302a4f0c66e25dcb364b7787478";
    hash = "sha256-5mKUHewXyGOWDre6gvTSD7asB/5fr3xhlqS2WdEsSbk=";
  };
in
stdenv.mkDerivation {
  pname = "precice-su2";
  inherit version;

  unpackPhase = ''
    runHook preUnpack

    cp -r ${su2_src} su2
    cp -r ${adapter_src} adapter

    chmod -R +w .

    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    export SU2_HOME=$PWD/su2

    ls -la
    pwd

    patchShebangs --build adapter/su2AdapterInstall
    ./adapter/su2AdapterInstall

    cd su2

    runHook postPatch
  '';

  configureFlags = [
    "--with-include=${precice}/include"
    "--with-lib=${precice}/lib"
  ]
  ++ lib.optional enableMPI [ "--enable-mpi" "--with-cc=${openmpi}/bin/mpicc" "--with-cxx=${openmpi}/bin/mpicxx" ]
  ++ lib.optional (!enableCgns) "--disable-cgns"
  ++ lib.optional (!enableDOT) "--disable-DOT"
  ++ lib.optional (!enableMSH) "--disable-MSH"
  ++ lib.optional (!enableDEF) "--disable-DEF"
  ++ lib.optional (!enableSOL) "--disable-SOL"
  ++ lib.optional (!enableGEO) "--disable-GEO";

  makeWrapperArgs = [
    "--prefix SU2_RUN : $out/bin"
  ];

  postInstall = ''
    wrapPythonProgramsIn "$out/bin" "$out $pythonPath"
  '';

  enableParallelBuilding = true;

  nativeBuildInputs = [
    autoreconfHook
    gcc
    python3
    pkg-config
    precice
    makeWrapper
    python3.pkgs.wrapPython
  ];
  propagatedBuildInputs = [ python3 python3.pkgs.numpy ];

  doCheck = true;

  meta = {
    description = "preCICE-adapter for the CFD code SU2";
    homepage = "https://github.com/precice/su2-adapter";
    license = with lib.licenses; [ lgpl21Only lgpl3Only ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
