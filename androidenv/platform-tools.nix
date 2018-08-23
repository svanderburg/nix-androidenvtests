{deployAndroidPackage, lib, package, os, autopatchelf, pkgs}:

deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf ];
  libs_x86_64 = lib.optionalString (os == "linux") (lib.makeLibraryPath [ pkgs.glibc pkgs.zlib pkgs.ncurses5 ]);
  patchInstructions = lib.optionalString (os == "linux") ''
    export libs=$packageBaseDir/lib64
    autopatchelf $packageBaseDir/lib64 libs --no-recurse
    autopatchelf $packageBaseDir libs --no-recurse
  '';
}
