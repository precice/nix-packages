[
  (self: super: {
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
  (self: super:
    {
      pyprecice = super.callPackage ./pyprecice { };
      petsc4py = super.callPackage ./petsc4py { };

      precice-aste = super.callPackage ./aste { };
      dealii = super.callPackage ./dealii { };
      precice-dealii-adapter = super.callPackage ./dealii-adapter { };
      precice-calculix-adapter = super.callPackage ./calculix-adapter { };
      precice-su2 = super.callPackage ./su2 { };

      fenics = super.callPackage ./fenics { };
      precice-fenics-adapter = super.callPackage ./precice-fenics-adapter { } ;

      openfoam = super.callPackage ./openfoam { };
      precice-openfoam-adapter = super.callPackage ./openfoam-adapter { };
    }
  )
]
