{deployAndroidPackage, lib, package, os, autopatchelf, makeWrapper, pkgs, platform-tools}:

let
  runtime_paths = lib.makeBinPath [ pkgs.coreutils pkgs.file pkgs.findutils pkgs.gawk pkgs.gnugrep pkgs.gnused pkgs.jdk pkgs.python3 pkgs.which ] + ":${platform-tools}/platform-tools";
in
deployAndroidPackage {
  inherit package os;
  buildInputs = [ autopatchelf makeWrapper ];
  libs_x86_64 = lib.optionalString (os == "linux") (lib.makeLibraryPath [ pkgs.glibc pkgs.stdenv.cc.cc pkgs.ncurses5 ]);
  patchInstructions = lib.optionalString (os == "linux") ''
    patchShebangs .

    patch -p1 \
      --no-backup-if-mismatch < ${./make_standalone_toolchain.py_18.patch}
    wrapProgram build/tools/make_standalone_toolchain.py --prefix PATH : "${runtime_paths}"

    # TODO: allow this stuff
    rm -rf docs sources tests
    # We only support cross compiling with gcc for now
    rm -rf toolchains/*-clang* toolchains/llvm*

    find toolchains \( \
        \( -type f -a -name "*.so*" \) -o \
        \( -type f -a -perm -0100 \) \
        \) -exec patchelf --set-interpreter ${pkgs.stdenv.cc.libc.out}/lib/ld-*so.? \
                          --set-rpath ${lib.makeLibraryPath [ pkgs.libcxx pkgs.zlib pkgs.ncurses5 ]} {} \;

    # fix ineffective PROGDIR / MYNDKDIR determination
    for i in ndk-build
    do
        sed -i -e 's|^PROGDIR=`dirname $0`|PROGDIR=`dirname $(readlink -f $(which $0))`|' $i
    done

    # Patch executables
    autopatchelf prebuilt/linux-x86_64/bin

    # wrap
    for i in ndk-build
    do
        wrapProgram "$(pwd)/$i" --prefix PATH : "${runtime_paths}"
    done

    # make some executables available in PATH
    mkdir -p $out/bin
    for i in ndk-build
    do
        ln -sf ../../libexec/android-sdk/ndk-bundle/$i $out/bin/$i
    done
  '';
}
