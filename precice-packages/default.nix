[
  (_: super: {
    lib = super.lib // {
      maintainers = super.lib.maintainers // {
        conni2461 = {
          email = "Simon-Hauser@outlook.de";
          name = "Simon Hauser";
          github = "conni2461";
          githubId = 15233006;
        };
      };
    };
  })
  (self: super: {
    # We fetch parmetis from archive.org because the server is not very reliable
    parmetis = super.parmetis.overrideAttrs (oA: {
      src = super.fetchurl {
        url = "https://web.archive.org/web/20221116225811/http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-${oA.version}.tar.gz";
        hash = "sha256-8tmiMbfPl/H+5ujJZjET6/bCQNQH08EYxVs2M9a+bl8=";
      };
    });

    # We need to pin hwloc otherwise petsc no longer builds
    hwloc = super.hwloc.overrideAttrs (_: rec {
      version = "2.9.1";

      src = super.fetchurl {
        url = "https://www.open-mpi.org/software/hwloc/v${super.lib.versions.majorMinor version}/downloads/hwloc-${version}.tar.bz2";
        sha256 = "sha256-fMSTGiD+9Ffgkzrz83W+bq+ncD/eIeE3v7loWxQJWZ4=";
      };
    });

    # We need to build petsc with support for hypre and parmetis, upstream does not have these features
    hypre = super.callPackage ./hypre { };
    petsc = super.petsc.overrideAttrs (oA: {
      buildInputs = oA.buildInputs ++ [
        super.metis
        self.parmetis
        self.hypre
        super.scalapack
      ];

      preConfigure = ''
        ${oA.preConfigure}
        configureFlagsArray+=(
          "--with-metis=1"
          "--with-parmetis=1"
          "--with-hypre=1"
          "--with-scalapack=1"
        )
      '';
    });

    pyprecice = super.callPackage ./pyprecice { };
    petsc4py = super.callPackage ./petsc4py { };

    precice-aste = super.callPackage ./aste { };
    dealii = super.callPackage ./dealii { };
    precice-dealii-adapter = super.callPackage ./dealii-adapter { };
    precice-calculix-adapter = super.callPackage ./calculix-adapter { };
    precice-su2 = super.callPackage ./su2 { };

    fenics = super.callPackage ./fenics { };
    fenics-mshr = super.callPackage ./fenics-mshr { };
    precice-fenics-adapter = super.callPackage ./precice-fenics-adapter { };

    precice-fortran-module = super.callPackage ./fortran-module { };
    precice-fortran-solverdummy = super.callPackage ./precice-fortran-solverdummy { };

    openfoam2206 = super.callPackage ./openfoam {
      version = "2206";
      hash = "sha256-snrFOsENf/siqFd1mzxAsYbw1ba67TXMgaNDpb26uX0=";
    };
    openfoam2212 = super.callPackage ./openfoam {
      version = "2212";
      hash = "sha256-yE1ey3f9WobR5bns+SrGXwMNtkWZNCXsNkjOo0NHqDo=";
    };
    openfoam2306 = super.callPackage ./openfoam {
      version = "2306";
      hash = "sha256-9+u52bqVXfirhTfFFX+CoqhRxJeOUQVcQHCRoxTfO5w=";
    };
    openfoam2312 = super.callPackage ./openfoam {
      version = "2312";
      hash = "sha256-xew1yydA5LFsmelE2d6OTefmTsBHDL0Fn5pT1GcrCmk=";
    };
    openfoam2406 = super.callPackage ./openfoam {
      version = "2406";
      hash = "sha256-vOXTZhZnTPqx7QDV7Me91MwEW40zquOifIF99l0yLZc=";
    };
    openfoam = self.openfoam2206;
    precice-openfoam-adapter = super.callPackage ./openfoam-adapter { };

    precice-aster = super.callPackage ./aster { };
    blacs = super.callPackage ./blacs { };
    mumps = super.callPackage ./mumps { };
    tfel = super.callPackage ./tfel { };

    precice-dune = super.callPackage ./dune { };

    mpibench = super.callPackage ./mpibench { };

    nutils = super.python3Packages.callPackage ./nutils { };
    bottombar = super.python3Packages.callPackage ./bottombar { };
  })
]
