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
  (_: super:
    {
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

      pyprecice = super.callPackage ./pyprecice { };
      petsc4py = super.callPackage ./petsc4py { };

      precice-aste = super.callPackage ./aste { };
      dealii = super.callPackage ./dealii { };
      precice-dealii-adapter = super.callPackage ./dealii-adapter { };
      precice-calculix-adapter = super.callPackage ./calculix-adapter { };
      precice-su2 = super.callPackage ./su2 { };

      fenics = super.callPackage ./fenics { };
      fenics-mshr = super.callPackage ./fenics-mshr { };
      precice-fenics-adapter = super.callPackage ./precice-fenics-adapter { } ;

      openfoam = super.callPackage ./openfoam { };
      precice-openfoam-adapter = super.callPackage ./openfoam-adapter { };

      precice-aster = super.callPackage ./aster { };
      blacs = super.callPackage ./blacs { };
      mumps = super.callPackage ./mumps { };
      tfel = super.callPackage ./tfel { };

      precice-dune = super.callPackage ./dune { };

      mpibench = super.callPackage ./mpibench { };

      nutils = super.python3Packages.callPackage ./nutils { };
      bottombar = super.python3Packages.callPackage ./bottombar { };
    }
  )
]
