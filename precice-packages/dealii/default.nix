{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gcc
}:

stdenv.mkDerivation rec {
  pname = "dealii";
  version = "9.4.1";

  src = fetchFromGitHub {
    owner = "dealii";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Kz78U5ud36cTMq4E8FclOsmNsjMZfz+23tRXW/sl498=";
  };

  nativeBuildInputs = [ cmake gcc ];

  doCheck = true;

  meta = {
    description = "An open source finite element library";
    homepage = "https://www.dealii.org/";
    license = with lib.licenses; [ lgpl21Only ];
    maintainers = with lib.maintainers; [ cheriimoya ];
    platforms = lib.platforms.unix;
  };
}
