{deployAndroidPackage, lib, package, os, autopatchelf, pkgs, pkgs_i686}:

deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf ];
  libs_x86_64 = lib.optionalString (os == "linux") lib.makeLibraryPath [ pkgs.glibc pkgs.xlibs.libX11 pkgs.xlibs.libXext pkgs.xlibs.libXdamage pkgs.xlibs.libXfixes pkgs.xlibs.libxcb pkgs.libGL pkgs.libpulseaudio pkgs.zlib pkgs.ncurses5 pkgs.stdenv.cc.cc ];
  libs_i386 = lib.optionalString (os == "linux") lib.makeLibraryPath [ pkgs_i686.glibc ];
  patchInstructions = lib.optionalString (os == "linux") ''
    export libs_i386=$packageBaseDir/lib:$libs_i386
    export libs_x86_64=$packageBaseDir/lib64:$packageBaseDir/lib64/qt/lib:$libs_x86_64
    autopatchelf $out
  '';
  dontMoveLib64 = true;
}
