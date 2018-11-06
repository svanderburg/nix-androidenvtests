{ pkgs ? import <nixpkgs> {}
, pkgs_i686 ? import <nixpkgs> { system = "i686-linux"; }
}:

let
  autopatchelf = import ../../nix-patchtools;
in
rec {
  composeAndroidPackages = import ./compose-android-packages.nix {
    inherit (pkgs) stdenv fetchurl requireFile makeWrapper unzip;
    inherit autopatchelf pkgs pkgs_i686;
  };

  buildApp = import ./build-app.nix {
    inherit (pkgs) stdenv jdk ant;
    inherit composeAndroidPackages;
  };

  emulateApp = import ./emulate-app.nix {
    inherit (pkgs) stdenv;
    inherit composeAndroidPackages;
  };

  androidPkgs_9_0 = composeAndroidPackages {
    platformVersions = [ "28" ];
    abiVersions = [ "x86" "x86_64"];
  };
}
