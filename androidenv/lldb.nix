{deployAndroidPackage, lib, package, os, autopatchelf, pkgs}:

deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf ];
  libs_x86_64 = lib.optionalString (os == "linux") (lib.makeLibraryPath [ pkgs.glibc pkgs.stdenv.cc.cc pkgs.zlib pkgs.openssl pkgs.ncurses5 ]);
  patchInstructions = lib.optionalString (os == "linux") ''
    export libs_x86_64=$packageBaseDir/lib:$libs_x86_64
    autopatchelf $packageBaseDir/lib
    autopatchelf $packageBaseDir/bin
  '';
}
