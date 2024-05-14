{
  stdenv,
  fetchFromGitHub,
  gfortran,
  ...
}:
stdenv.mkDerivation {
  name = "precice-fortran-module";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "fortran-module";
    rev = "9e3f40569a4ac0538aea7abb8e0f453141c700cd";
    hash = "sha256-s7wdopHDdkQtffTQdGQheXSb98vp1+Y351YK/76UjIQ=";
  };

  nativeBuildInputs = [ gfortran ];

  installPhase = ''
    mkdir -p $out/lib
    cp precice.mod $out/lib/
  '';
}
