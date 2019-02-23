{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" ]
, config ? { android_sdk.accept_license = true; }
, buildPlatformVersions ? [ "16" ]
, emulatePlatformVersions ? [ "23" ]
, abiVersions ? [ "x86" ]
, useUpstream ? false
}:

let
  sdkJobset = import ./sdk-jobset.nix {
    inherit nixpkgs systems config buildPlatformVersions emulatePlatformVersions abiVersions useUpstream;
  };
  ndkJobset = import ./ndk-jobset.nix {
    inherit nixpkgs systems config buildPlatformVersions emulatePlatformVersions abiVersions useUpstream;
  };
in
sdkJobset // ndkJobset
