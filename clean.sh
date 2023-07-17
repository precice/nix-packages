#!/bin/sh
set -eux

cd $HOME

[ -d .local/share/nix ] && chmod +w -R .local/share/nix

rm -rf .nix* .bin/nix-static .local/state/nix .local/share/nix .cache/nix .config/nix
