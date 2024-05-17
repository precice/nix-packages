{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  mpi,
  gfortran,
  blas,
  lapack,
}:
stdenv.mkDerivation rec {
  pname = "hypre";
  version = "2.28.0";

  src =
    fetchFromGitHub {
      owner = "hypre-space";
      repo = "hypre";
      rev = "v${version}";
      hash = "sha256-/k2ijrre1xYT5cYrW4QbH3spgifWErXE7CnQFH01cnI=";
    }
    + "/src/";

  nativeBuildInputs = [
    cmake
    mpi
    gfortran
    blas
    lapack
  ];

  meta = {
    description = "Parallel solvers for sparse linear systems featuring multigrid methods.";
    homepage = "www.llnl.gov/casc/hypre/";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
