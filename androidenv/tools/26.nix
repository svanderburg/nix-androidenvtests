{deployAndroidPackage, requireFile, lib, autopatchelf, makeWrapper, os, pkgs, pkgs_i686, postInstall ? ""}:

deployAndroidPackage {
  inherit os;
  buildInputs = [ autopatchelf makeWrapper ];
  libs_x86_64 = lib.optionalString (os == "linux") lib.makeLibraryPath [ pkgs.glibc pkgs.xlibs.libX11 pkgs.xlibs.libXrender pkgs.xlibs.libXext pkgs.fontconfig pkgs.freetype ];
  libs_i386 = lib.optionalString (os == "linux") lib.makeLibraryPath [ pkgs_i686.glibc pkgs_i686.xlibs.libX11 pkgs_i686.xlibs.libXrender pkgs_i686.xlibs.libXext pkgs_i686.fontconfig pkgs_i686.freetype pkgs_i686.zlib ];
  package = {
    name = "tools";
    path = "tools";
    revision = "26.0.1";
    archives = {
      linux = requireFile {
        url = https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip;
        sha256 = "185yq7qwxflw24ccm5d6zziwlc9pxmsm3f54pm9p7xm0ik724kj4";
      };
      macosx = requireFile {
        url = https://dl.google.com/android/repository/sdk-tools-darwin-3859397.zip;
        sha256 = "1ycx9gzdaqaw6n19yvxjawywacavn1jc6sadlz5qikhgfr57b0aa";
      };
    };
  };
  patchInstructions = ''
    ${lib.optionalString (os == "linux") ''
      # Auto patch all binaries
      autopatchelf .
    ''}

    # Wrap all scripts that require JAVA_HOME
    for i in bin
    do
        find $i -maxdepth 1 -type f -executable | while read program
        do
            if grep -q "JAVA_HOME" $program
            then
                wrapProgram $PWD/$program --prefix PATH : ${pkgs.jdk8}/bin
            fi
        done
    done

    # Wrap monitor script
    wrapProgram $PWD/monitor \
      --prefix PATH : ${pkgs.jdk8}/bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.xlibs.libX11 pkgs.xlibs.libXtst ]}

    # Patch all script shebangs
    patchShebangs .

    cd ..
    ${postInstall}
  '';
}
