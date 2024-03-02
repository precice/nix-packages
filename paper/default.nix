{ sha, pkgs ? import <nixpkgs> {}, ... }:
pkgs.stdenv.mkDerivation {
  name = "Reproducibility Research Paper";

  src = ./.;

  nativeBuildInputs = with pkgs; [
    (python3.withPackages (ps: with ps; [ pygments ]))
    which
    texlive.combined.scheme-full
    gnumake
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp paper.pdf $out/hauser-hausch-research-paper-${sha}.pdf

    runHook postInstall
  '';
}
