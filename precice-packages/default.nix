[
  (self: super:
    rec {
      pyprecice = super.callPackage ./pyprecice { };
      petsc4py = super.callPackage ./petsc4py { };

      precice-aste = super.callPackage ./aste { };
      dealii = super.callPackage ./dealii { };
      precice-dealii-adapter = super.callPackage ./dealii-adapter { };
      precice-calculix-adapter = super.callPackage ./calculix-adapter { };
      precice-su2 = super.callPackage ./su2 { };

      fenics = super.callPackage ./fenics { };
      precice-fenics-adapter = super.callPackage ./precice-fenics-adapter { } ;
    }
  )
]
