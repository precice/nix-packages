# Timings of the builds

- dealii
22.11: nix build .\#dealii  1.39s user 0.77s system 0% cpu 11:36.47 total

- precice-dealii-adapter
22.11: nix build .\#precice-dealii-adapter  0.95s user 0.42s system 5% cpu 23.704 total

- precice-fenics-adapter
22.11: nix build .\#precice-fenics-adapter  0.98s user 0.49s system 8% cpu 17.478 total
NIXPKGS_ALLOW_INSECURE=1 nix build --impure .\#precice-fenics-adapter  1.63s user 0.92s system 0% cpu 7:45.16 total

- precice-calculix-adapter
22.11: nix build .\#precice-calculix-adapter  0.95s user 0.34s system 3% cpu 41.641 total
nix build .\#precice-calculix-adapter  1.09s user 0.33s system 3% cpu 42.915 total

- precice-aste
22.11: nix build .\#precice-aste  2.94s user 1.28s system 0% cpu 17:17.09 total

- nutils (with checks)
nix build .\#nutils  0.57s user 0.23s system 0% cpu 5:45.33 total

- parmetis
nix build .\#parmetis  0.92s user 0.28s system 3% cpu 37.208 total

- openfoam
nix build .\#openfoam  6.09s user 2.40s system 0% cpu 57:33.15 total

- openfoam-adapter
nix build .\#precice-openfoam-adapter  1.00s user 0.30s system 4% cpu 30.647 total

- vm-light
nix build .\#vm-light  6.17s user 2.93s system 2% cpu 6:50.80 total

- vm
nix build .#vm  8.15s user 2.25s system 0% cpu 27:40.26 total

# hb01

AMD Ryzen 9 5950X 16-Core Processor
128GB RAM
NVMe SSD

- openfoam
nix build .#openfoam --max-jobs 0  5.11s user 1.99s system 0% cpu 28:11.10 total

- precice-openfoam-adapter
nix build .\#precice-openfoam-adapter --max-jobs 0  2.30s user 0.63s system 13% cpu 21.737 total

- precice-aster
nix build --impure .\#precice-aster --max-jobs 0  3.35s user 1.28s system 1% cpu 6:30.31 total

- precice-su2
nix build --impure .\#precice-su2 --max-jobs 0  1.65s user 0.48s system 1% cpu 2:17.20 total

- dealii
nix build --impure .\#dealii --max-jobs 0  0.88s user 0.42s system 0% cpu 5:55.81 total

- precice-dealii-adapter
nix build .\#precice-dealii-adapter --max-jobs 0  1.55s user 0.39s system 11% cpu 17.428 total

- precice-dune
NIXPKGS_ALLOW_INSECURE=1 nix build --impure .\#precice-dune --max-jobs 0  2.17s user 0.70s system 0% cpu 6:21.02 total
