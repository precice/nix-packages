#!/bin/sh
set -eu

echo "-- Ensure everything is setup"
if [ -z "${XDG_DATA_HOME+set}" ]; then
  XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z "${XDG_CONFIG_HOME+set}" ]; then
  XDG_CONFIG_HOME="$HOME/.config"
fi

echo "-- Create directories"
mkdir -p "$HOME/.bin" # For holding the binaries
mkdir -p "$XDG_CONFIG_HOME/nix" # For the Nix config file

echo "-- Add .bin to the PATH variable in the .profile if not already set"
if [ "$(grep 'export PATH=$PATH:$HOME/.bin' "$HOME/.profile" -c)" -eq 0 ]; then
  echo 'export PATH=$PATH:$HOME/.bin' >> "$HOME/.profile"
fi

echo "-- Download Nix"
if [ ! -f "$HOME/.bin/nix-static" ]; then
  wget https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist -O "$HOME/.bin/nix-static"
fi
chmod 755 "$HOME/.bin/nix-static"

echo "-- Write the nix.conf file if it doesn't exist"
if [ ! -f "$XDG_CONFIG_HOME/nix/nix.conf" ]; then
  cat <<EOF > "$XDG_CONFIG_HOME/nix/nix.conf"
store = $XDG_DATA_HOME/nix/root
experimental-features = nix-command flakes
EOF
fi

echo "-- Obtaining Nix from upstream"
$HOME/.bin/nix-static build nixpkgs#nix nixpkgs#bashInteractive --no-link
