{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  mpi,
  perl,
}:
stdenv.mkDerivation rec {
  pname = "mpibench";
  version = "unstable-2019-02-01";

  src = fetchFromGitHub {
    owner = "llnl";
    repo = pname;
    rev = "4c855b8d4d192b67dff1fbc37ec4bc82333f3c0b";
    hash = "sha256-8XYTp/c9O95cEspazpN7gHv9NZE1RDP9wBmekinXN2k=";
  };

  postPatch = ''
    substituteInPlace crunch_mpiBench --replace '#!/usr/bin/perl' '#!${perl}/bin/perl'
  '';

  nativeBuildInputs = [
    gcc
    mpi
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp mpiBench crunch_mpiBench $out/bin
  '';

  meta = {
    description = ''MPI benchmark to test and measure collective performance'';
    homepage = "https://github.com/LLNL/mpiBench";
    license = with lib.licenses; [ unlicense ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
