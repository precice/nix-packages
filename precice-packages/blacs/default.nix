{
  lib,
  stdenv,
  fetchurl,
  bash,
  gcc,
  gfortran,
  openmpi,
}:
stdenv.mkDerivation {
  pname = "blacs";
  version = "1.1";

  src = fetchurl {
    url = "http://www.netlib.org/blacs/mpiblacs.tgz";
    hash = "sha256-iN1yZdQSAilI3rt6JzcibNU6O/c7C2L8Vc6zzMilmPc=";
  };

  preBuild = ''
    cat <<EOF > ./Bmake.inc
    SHELL = ${bash}/bin/bash

    BTOPdir = $PWD
    COMMLIB = MPI
    PLAT = LINUX

    BLACSdir    = \$(BTOPdir)/LIB
    BLACSDBGLVL = 0
    BLACSFINIT  = \$(BLACSdir)/libblacsF77init_\$(COMMLIB)-\$(PLAT)-\$(BLACSDBGLVL).a
    BLACSCINIT  = \$(BLACSdir)/libblacsCinit_\$(COMMLIB)-\$(PLAT)-\$(BLACSDBGLVL).a
    BLACSLIB    = \$(BLACSdir)/libblacs_\$(COMMLIB)-\$(PLAT)-\$(BLACSDBGLVL).a

    MPIdir = ${openmpi}
    MPILIBdir = ${openmpi}/lib
    MPIINCdir = ${openmpi}/include
    MPILIB = ${openmpi}/lib/libmpi.a

    BTLIBS = \$(BLACSFINIT) \$(BLACSLIB) \$(BLACSFINIT) \$(MPILIB)

    INSTdir = $out

    TESTdir = \$(BTOPdir)/TESTING/EXE
    FTESTexe = \$(TESTdir)/xFbtest_\$(COMMLIB)-\$(PLAT)-\$(BLACSDBGLVL)
    CTESTexe = \$(TESTdir)/xCbtest_\$(COMMLIB)-\$(PLAT)-\$(BLACSDBGLVL)

    SYSINC = -I\$(MPIINCdir)
    INTFACE = -Df77IsF2C
    SENDIS =
    BUFF =
    WHATMPI =
    SYSERRORS =
    DEBUGLVL = -DBlacsDebugLvl=\$(BLACSDBGLVL)

    DEFS1 = -DSYSINC \$(SYSINC) \$(INTFACE) \$(DEFBSTOP) \$(DEFCOMBTOP) \$(DEBUGLVL)
    BLACSDEFS = \$(DEFS1) \$(SENDIS) \$(BUFF) \$(TRANSCOMM) \$(WHATMPI) \$(SYSERRORS)

    F77            = mpif77
    F77NO_OPTFLAGS =
    F77FLAGS       = \$(F77NO_OPTFLAGS) -O
    F77LOADER      = \$(F77)
    F77LOADFLAGS   =
    CC             = mpicc
    CCFLAGS        = -O2
    CCLOADER       = \$(CC)
    CCLOADFLAGS    =

    ARCH      = ar
    ARCHFLAGS = r
    RANLIB    = ranlib
    EOF

    cat Bmake.inc
  '';

  buildPhase = ''
    runHook preBuild

    make -j mpi

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/{include,lib}

    cp SRC/MPI/Bconfig.h $out/include
    cp SRC/MPI/Bdef.h $out/include

    cp LIB/*.a $out/lib
  '';

  nativeBuildInputs = [
    gcc
    gfortran
    openmpi
  ];

  enableParallelBuilding = true;

  meta = {
    description = " The BLACS (Basic Linear Algebra Communication Subprograms) project is an ongoing investigation whose purpose is to create a linear algebra oriented message passing interface that may be implemented efficiently and uniformly across a large range of distributed memory platforms. ";
    homepage = "https://www.netlib.org/blacs/";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ conni2461 ];
    platforms = lib.platforms.unix;
  };
}
