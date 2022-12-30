[
  (self: super:
    rec {
      dealii = super.callPackage ./dealii { };
      precice-dealii-adapter = super.callPackage ./dealii-adapter { };
    }
  )
]
