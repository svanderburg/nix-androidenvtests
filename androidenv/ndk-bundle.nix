{deployAndroidPackage, lib, package, os, autopatchelf, pkgs}:

deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf ];
  patchInstructions = lib.optionalString (os == "linux") ''
  '';
}
