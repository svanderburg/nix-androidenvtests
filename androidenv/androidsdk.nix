{stdenv, fetchurl, requireFile, makeWrapper, unzip, autopatchelf, pkgs, pkgs_i686}:

{ toolsVersion ? "25.2.5"
, platformToolsVersion ? "28.0.0"
, buildToolsVersions ? [ "28.0.0" ]
, includeEmulator ? false
, emulatorVersion ? "28.0.2"
, platformVersions ? []
, includeSources ? false
, includeDocs ? false
, includeSystemImages ? false
, systemImageTypes ? [ "default" ]
, abiVersions ? [ "armeabi-v7a" ]
, lldbVersions ? [ ]
, cmakeVersions ? [ ]
, includeNDK ? false
, ndkVersion ? "17.1.4828580"
, useGoogleAPIs ? false
, useGoogleTVAddOns ? false
, includeExtras ? []
}@args:

let
  inherit (pkgs) stdenv fetchurl makeWrapper unzip;

  # Determine the Android os identifier from Nix's system identifier
  os = if stdenv.system == "x86_64-linux" then "linux"
    else if stdenv.system == "x86_64-darwin" then "macosx"
    else "No tarballs found for system architecture: ${stdenv.system}";

  # Generated Nix packages
  packages = import ./generated/packages.nix {
    inherit fetchurl;
  };

  # Generated system images
  system-images-packages = import ./generated/system-images.nix {
    inherit fetchurl;
  };

  # Generated addons
  addons = import ./generated/addons.nix {
    inherit fetchurl;
  };
in
rec {
  deployAndroidPackage = import ./deploy-androidpackage.nix {
    inherit stdenv unzip;
  };

  platform-tools = import ./platform-tools.nix {
    inherit deployAndroidPackage os autopatchelf pkgs;
    inherit (stdenv) lib;
    package = packages.platform-tools."${platformToolsVersion}";
  };

  build-tools = map (version:
    import ./build-tools.nix {
      inherit deployAndroidPackage os autopatchelf makeWrapper pkgs pkgs_i686;
      inherit (stdenv) lib;
      package = packages.build-tools."${version}";
    }
  ) buildToolsVersions;

  docs = deployAndroidPackage {
    inherit os;
    package = packages.docs."1";
  };

  emulator = import ./emulator.nix {
    inherit deployAndroidPackage os autopatchelf makeWrapper pkgs pkgs_i686;
    inherit (stdenv) lib;
    package = packages.emulator."${emulatorVersion}"."${os}";
  };

  platforms = map (version:
    deployAndroidPackage {
      inherit os;
      package = packages.platforms."${version}";
    }
  ) platformVersions;

  sources = stdenv.lib.optional includeSources (map (version:
    deployAndroidPackage {
      inherit os;
      package = packages.sources."${version}";
    }
  ) platformVersions);

  system-images = stdenv.lib.flatten (map (apiVersion:
    map (type:
      map (abiVersion:
        deployAndroidPackage {
          inherit os;
          package = system-images-packages.${apiVersion}.${type}.${abiVersion};
        }
      ) abiVersions
    ) systemImageTypes
  ) platformVersions);

  lldb = map (version:
    import ./lldb.nix {
      inherit deployAndroidPackage os autopatchelf pkgs;
      inherit (stdenv) lib;
      package = packages.lldb."${version}";
    }
  ) lldbVersions;

  cmake = map (version:
    import ./cmake.nix {
      inherit deployAndroidPackage os autopatchelf pkgs;
      inherit (stdenv) lib;
      package = packages.cmake."${version}";
    }
  ) cmakeVersions;

  ndk-bundle = import ./ndk-bundle.nix {
    inherit deployAndroidPackage os autopatchelf pkgs;
    inherit (stdenv) lib;
    package = packages.ndk-bundle."${ndkVersion}";
  };

  google-apis = map (version:
    deployAndroidPackage {
      inherit os;
      package = addons.addons."${version}".google_apis;
    }  
  ) platformVersions;

  google-tv-addons = map (version:
    deployAndroidPackage {
      inherit os;
      package = addons.addons."${version}".google_tv_addon;
    }
  ) platformVersions; 

  # This derivation deploys the tools package and symlinks all the desired
  # plugins that we want to use.

  androidsdk = import ./tools.nix {
    inherit deployAndroidPackage requireFile packages toolsVersion autopatchelf makeWrapper os pkgs pkgs_i686;
    inherit (stdenv) lib;

    postInstall = ''
      # Symlink all requested plugins

      ln -s ${platform-tools}/libexec/android-sdk/* platform-tools

      ${stdenv.lib.optionalString (build-tools != []) ''
        mkdir -p build-tools
        ${stdenv.lib.concatMapStrings (buildTool: ''
          ln -s ${buildTool}/libexec/android-sdk/build-tools/* build-tools
        '') build-tools}
      ''}

      ${stdenv.lib.optionalString includeEmulator ''
        ln -s ${emulator}/libexec/android-sdk/* emulator
      ''}

      ${stdenv.lib.optionalString includeDocs ''
        ln -s ${docs}/libexec/android-sdk/* docs
      ''}

      mkdir -p platforms
      ${stdenv.lib.optionalString (platforms != []) ''
        mkdir -p platforms
        ${stdenv.lib.concatMapStrings (platform: ''
          ln -s ${platform}/libexec/android-sdk/platforms/* platforms
        '') platforms}
      ''}
      ${stdenv.lib.optionalString includeSources ''
        mkdir -p sources
        ${stdenv.lib.concatMapStrings (source: ''
          ln -s ${source}/libexec/android-sdk/sources/* sources
        '') sources}
      ''}
      ${stdenv.lib.optionalString (lldb != []) ''
        mkdir -p lldb
        ${stdenv.lib.concatMapStrings (lldb: ''
          ln -s ${lldb}/libexec/android-sdk/lldb/* lldb
        '') lldb}
      ''}
      ${stdenv.lib.optionalString (cmake != []) ''
        mkdir -p cmake
        ${stdenv.lib.concatMapStrings (cmake: ''
          ln -s ${cmake}/libexec/android-sdk/cmake/* cmake
        '') cmake}
      ''}
      ${stdenv.lib.optionalString includeNDK ''
        ln -s ${ndk-bundle}/libexec/android-sdk/* ndk-bundle
      ''}
      ${stdenv.lib.optionalString includeSystemImages ''
        mkdir -p system-images
        ${stdenv.lib.concatMapStrings (system-image: ''
          apiVersion=$(basename $(echo ${system-image}/libexec/android-sdk/system-images/*))
          type=$(basename $(echo ${system-image}/libexec/android-sdk/system-images/*/*))
          mkdir -p system-images/$apiVersion/$type
          ln -s ${system-image}/libexec/android-sdk/system-images/$apiVersion/$type/* system-images/$apiVersion/$type
        '') system-images}
      ''}
      ${stdenv.lib.optionalString useGoogleAPIs ''
        mkdir -p add-ons
        ${stdenv.lib.concatMapStrings (addon: ''
          ln -s ${addon}/libexec/android-sdk/add-ons/* add-ons
        '') google-apis}
      ''}
      ${stdenv.lib.optionalString useGoogleTVAddOns ''
        mkdir -p add-ons
        ${stdenv.lib.concatMapStrings (addon: ''
          ln -s ${addon}/libexec/android-sdk/add-ons/* add-ons
        '') google-tv-addons}
      ''}
      ${stdenv.lib.concatMapStrings (identifier:
        let
          path = addons.extras."${identifier}".path;
          addon = deployAndroidPackage {
            inherit os;
            package = addons.extras."${identifier}";
          };
        in
        ''
          targetDir=$(dirname ${path})
          mkdir -p $targetDir
          ln -s ${addon}/libexec/android-sdk/${path} $targetDir
        '') includeExtras}

      # Expose common executables in bin/
      mkdir -p $out/bin
      find $PWD/tools -not -path '*/\.*' -type f -executable -mindepth 1 -maxdepth 1 | while read i
      do
          ln -s $i $out/bin
      done  

      find $PWD/tools/bin -not -path '*/\.*' -type f -executable -mindepth 1 -maxdepth 1 | while read i
      do
          ln -s $i $out/bin
      done

      ln -s $PWD/platform-tools/adb $out/bin
    '';
  };
}
