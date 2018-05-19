{deployAndroidPackage, lib, package, os, autopatchelf, pkgs}:

deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf ];
  libs_x86_64 = lib.makeLibraryPath [ pkgs.stdenv.glibc pkgs.stdenv.cc.cc ];
  patchInstructions = lib.optionalString (os == "linux") ''
    autopatchelf $packageBaseDir/bin
  '';
}
