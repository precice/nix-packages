{
  lib,
  python3,
  openmpi,
  openssh,
  petsc,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "petsc4py";
  version = "3.19.1";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-0E3vmZXtY5XhJcYF2haUONd9QQ1QGdxXvkLkKK3jAZA=";
  };

  PETSC_DIR = "${petsc}";

  # The "build_src --force" flag is used to re-build the package's cython code.
  # This prevents issues when using multiple cython-based packages
  # together (for example, mpi4py and petsc4py) due to code that has been
  # generated with incompatible cython versions.
  setupPyBuildFlags = [ "build_src --force" ];

  nativeBuildInputs = with python3.pkgs; [
    cython
    openmpi
    openssh
  ];
  propagatedBuildInputs = with python3.pkgs; [ numpy ];
  checkInputs = with python3.pkgs; [ pytest ];

  doCheck = false;

  meta = {
    description = "Python bindings for PETSc, the Portable, Extensible Toolkit for Scientific Computation";
    homepage = "https://bitbucket.org/petsc/petsc4py";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
