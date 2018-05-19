{deployAndroidPackage, lib, package, os, autopatchelf, makeWrapper, pkgs, pkgs_i686}:

deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf makeWrapper ];
  libs_x86_64 = lib.optionalString (os == "linux") lib.makeLibraryPath [ pkgs.glibc pkgs.zlib pkgs.ncurses5 ];
  libs_i386 = lib.optionalString (os == "linux") lib.makeLibraryPath [ pkgs_i686.glibc pkgs_i686.zlib pkgs_i686.ncurses5 ];
  patchInstructions = ''
    ${lib.optionalString (os == "linux") ''
      export libs_i386=$packageBaseDir/lib:$libs_i386
      export libs_x86_64=$packageBaseDir/lib64:$libs_x86_64
      autopatchelf $packageBaseDir/lib64 libs --no-recurse
      autopatchelf $packageBaseDir libs --no-recurse
    ''}

    wrapProgram $PWD/mainDexClasses \
      --prefix PATH : ${pkgs.jdk8}/bin
  '';
  noAuditTmpdir = true; # The checker script gets confused by the build-tools path that is incorrectly identified as a reference to /build
}
