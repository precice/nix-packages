{ lib, stdenv, fetchFromGitHub, cmake, precice, dealii, enable3d ? false }:

stdenv.mkDerivation {
  pname = "precice-dealii-adapter";
  version = "unstable-2022-09-23";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "dealii-adapter";
    rev = "dbb25bea51531b7e4e0c9b5e4def3a7fadf8367c";
    hash = "sha256-pPQ2YEWiHPI4ph9mK3250TVzsAf9z5uYNae2jlflgUE=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ precice dealii ];

  cmakeFlags = lib.optionals enable3d [
    "-DDIM=3"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp elasticity $out/bin/elasticity
  '';

  meta = {
    description = "A coupled structural solver written with the C++ finite element library deal.II";
    homepage = "https://precice.org/adapter-dealii-overview.html";
    license = with lib.licenses; [ lgpl3 ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    mainProgram = "elasticity";
    platforms = lib.platforms.unix;
  };
}
