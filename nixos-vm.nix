{ config, pkgs, lib, fetchFromGitHub, ... }:
let
  release = "22.11";
  home-manager-tarball = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-${release}.tar.gz";
    sha256 = "sha256:0w1dfwl4i1ldwn2yaw63c4m3sxv3x72knmjvw4f4x1klqzkf5vsf";
  };
in {
  imports = [ ./configuration.nix (import "${home-manager-tarball}/nixos") ];


}
