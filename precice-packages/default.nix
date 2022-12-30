[
  (self: super:
    rec {
      dealii = super.callPackage ./dealii { };
      precice-dealii-adapter = super.callPackage ./dealii-adapter { };
      precice-calculix-adapter = super.callPackage ./calculix-adapter { };
    }
  )
]
