{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  openfoam,
  precice,
  writeScript,

  debugMode ? false,
  enableTimings ? false
}:

stdenv.mkDerivation rec {
  pname = "precice-openfoam-adapter";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "openfoam-adapter";
    rev = "v${version}";
    sha256 = "sha256-+8VfiKIXzWXu2L/hd3IJV56BBWM/Nb73DWv4BTHvBbQ=";
  };

  nativeBuildInputs = [ openfoam pkg-config precice ];

  buildPhase = ''
    source ${openfoam}/bin/set-openfoam-vars

    export FOAM_USER_LIBBIN=$PWD
    export ADAPTER_TARGET_DIR=$PWD
    export ADAPTER_PREP_FLAGS="${lib.optionalString debugMode "-DADAPTER_DEBUG_MODE"} ${lib.optionalString enableTimings "-DADAPTER_ENABLE_TIMINGS"}"

    ./Allwmake -j -q
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libpreciceAdapterFunctionObject.so $out/lib/
  '';

  meta = {
    description = "An OpenFOAM function object for CHT, FSI, and fluid-fluid coupled simulations using preCICE";
    homepage = "https://precice.org/adapter-openfoam-overview.html";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    mainProgram = "elasticity";
    platforms = lib.platforms.unix;
  };
}
