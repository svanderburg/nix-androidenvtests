{ pkgs ? import <nixpkgs> {}
, pkgs_i686 ? import <nixpkgs> { system = "i686-linux"; }
}:

let
  autopatchelf = import ../../nix-patchtools;
in
rec {
  androidsdk = import ./androidsdk.nix {
    inherit (pkgs) stdenv fetchurl requireFile makeWrapper unzip;
    inherit autopatchelf pkgs pkgs_i686;
  };

  buildApp = import ./build-app.nix {
    inherit (pkgs) stdenv jdk ant;
    inherit androidsdk;
  };

  emulateApp = import ./emulate-app.nix {
    inherit (pkgs) stdenv;
    inherit androidsdk;
  };
}
