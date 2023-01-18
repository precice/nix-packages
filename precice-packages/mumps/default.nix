{ lib
, stdenv
, fetchurl
, gcc
, gfortran
, openmpi
, blas
, liblapack
, metis
, parmetis
, scotch
, scalapack
, blacs
}:
let
  scotch_full = (scotch.overrideAttrs (oA: rec {
    buildFlags = [ "scotch ptscotch esmumps ptesmumps" ];

    enableParallelBuilding = true;
  }));
in
stdenv.mkDerivation rec {
  pname = "mumps";
  version = "5.5.1";

  src = fetchurl {
    url = "https://graal.ens-lyon.fr/MUMPS/MUMPS_${version}.tar.gz";
    sha256 = "sha256-Gr/ylPpH7kz9UN/VxZWUK3Lr/O3OCBQqdamas1AU+hU=";
  };

  preBuild = ''
    sed -i '16d' Makefile
    sed -i '23d' Makefile

    cat <<EOF > ./Makefile.inc
    # Begin orderings
    ISCOTCH   = -I${scotch_full}/include
    LSCOTCH   = -L${scotch_full}/lib -lptesmumps -lptscotch -lptscotcherr

    LPORDDIR = \$(topdir)/PORD/lib/
    IPORD    = -I\$(topdir)/PORD/include/
    LPORD    = -L\$(LPORDDIR) -lpord

    IMETIS    = -I${metis}/include -I${parmetis}/include
    LMETIS    = -L${metis}/lib -L${parmetis}/lib -lparmetis -lmetis

    # Corresponding variables reused later
    ORDERINGSF = -Dmetis -Dpord -Dparmetis -Dscotch -Dptscotch
    ORDERINGSC  = \$(ORDERINGSF)

    LORDERINGS = \$(LMETIS) \$(LPORD) \$(LSCOTCH)
    IORDERINGSF = \$(ISCOTCH)
    IORDERINGSC = \$(IMETIS) \$(IPORD) \$(ISCOTCH)
    # End orderings
    ################################################################################

    PLAT    =
    LIBEXT_SHARED  = .so
    FPIC_OPT = -fPIC
    LIBEXT  = .a
    OUTC    = -o
    OUTF    = -o
    RM = /bin/rm -f
    CC = mpicc
    FC = mpif90
    FL = mpif90
    AR = ar vr ""
    RANLIB = ranlib
    LAPACK = -llapack -L${liblapack}/lib
    LIBBLAS = -lblas -L${blas}/lib
    SCALAP  = -lscalapack -L${scalapack}/lib -L${blacs}/lib -lblacs_MPI-LINUX-0

    INCPAR = # not needed with mpif90/mpicc: -I/usr/include/openmpi
    LIBPAR = \$(SCALAP) \$(LAPACK) \$(LIBBLAS) # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi

    CDEFS   = -DAdd_

    #Begin Optimized options
    OPTF    = -O -fopenmp -fallow-argument-mismatch
    OPTL    = -O -fopenmp
    OPTC    = -O -fopenmp
    #End Optimized options

    INCS = \$(INCPAR)
    LIBS = \$(LIBPAR)
    LIBSEQNEEDED =
    EOF
  '';

  nativeBuildInputs = [ gcc gfortran openmpi ];

  installPhase = ''
    mkdir -p $out/{include,lib}

    cp include/*.h $out/include
    cp lib/*.a $out/lib
  '';

  enableParallelBuilding = true;

  meta = {
    description = "MUltifrontal Massively Parallel sparse direct Solver: A parallel sparse direct solver";
    homepage = "https://mumps-solver.org";
    license = with lib.licenses; [ cecill-c ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
