{ androidsdk, stdenv, ant, jdk }:

{ name
, release ? false, keyStore ? null, keyAlias ? null, keyStorePassword ? null, keyAliasPassword ? null
, antFlags ? ""
, ...
}@args:

assert release -> keyStore != null && keyAlias != null && keyStorePassword != null && keyAliasPassword != null;

let
  androidSdkArgNames = builtins.attrNames (builtins.functionArgs androidsdk);
  extraParams = removeAttrs args ([ "name" ] ++ androidSdkArgNames);

  # Extract the parameters meant for the Android SDK
  androidParams = builtins.intersectAttrs (builtins.functionArgs androidsdk) args;

  androidsdkComposition = (androidsdk androidParams).androidsdk;
in
stdenv.mkDerivation ({
  name = stdenv.lib.replaceChars [" "] [""] name; # Android APKs cannot contain white spaces in their names
  ANDROID_HOME = "${androidsdkComposition}/libexec/android-sdk";
  buildInputs = [ jdk ant ];
  buildPhase = ''
    ${stdenv.lib.optionalString release ''
      # Provide key singing attributes
      ( echo "key.store=${keyStore}"
        echo "key.alias=${keyAlias}"
        echo "key.store.password=${keyStorePassword}"
        echo "key.alias.password=${keyAliasPassword}"
      ) >> ant.properties
    ''}

    export ANDROID_SDK_HOME=`pwd` # Key files cannot be stored in the user's home directory. This overrides it.

    ant ${antFlags} ${if release then "release" else "debug"}
  '';
  installPhase = ''
    mkdir -p $out
    mv bin/*-${if release then "release" else "debug"}.apk $out

    mkdir -p $out/nix-support
    echo "file binary-dist \"$(echo $out/*.apk)\"" > $out/nix-support/hydra-build-products
  '';
} // extraParams)
