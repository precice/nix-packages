[
  (self: super:
    rec {
      precice-aste = super.callPackage ./aste { };
      dealii = super.callPackage ./dealii { };
      precice-dealii-adapter = super.callPackage ./dealii-adapter { };
      precice-calculix-adapter = super.callPackage ./calculix-adapter { };
      precice-su2 = super.callPackage ./su2 { };
    }
  )
]
