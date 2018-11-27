{androidenv}:

let
  androidComposition = androidenv.composeAndroidPackages {
    toolsVersion = "25.2.5";
    includeEmulator = false;
    platformVersions = [ "24" ];
    includeSources = true;
    includeDocs = true;
    includeSystemImages = true;
    systemImageTypes = [ "default" ];
    abiVersions = [ "armeabi-v7a" ];
    lldbVersions = [ "2.0.2558144" ];
    cmakeVersions = [ "3.6.4111459" ];
    includeNDK = true;
    useGoogleAPIs = false;
    useGoogleTVAddOns = false;
    includeExtras = [
      "extras;google;gcm"
    ];
  };
in
androidComposition.androidsdk
