{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" ]
, config ? { android_sdk.accept_license = true; }
, buildPlatformVersions ? [ "16" ]
, emulatePlatformVersions ? [ "23" ]
, abiVersions ? [ "x86" ]
, useUpstream ? false
}:

let
  getAndroidEnv = pkgs:
    if useUpstream then pkgs.androidenv else import ../../androidenv {
      inherit pkgs;
    };
in
rec {
  # hello-jni jobs

  hello_jni_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./hello-jni {
            inherit androidenv;
            platformVersion = buildPlatformVersion;
            release = false;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);

  hello_jni_release = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./hello-jni {
            inherit androidenv;
            platformVersion = buildPlatformVersion;
            release = true;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);

  emulate_hello_jni_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = builtins.listToAttrs (map (emulatePlatformVersion:

            { name = "emulate_" + emulatePlatformVersion;
              value = builtins.listToAttrs (map (abiVersion:

                { name = abiVersion;
                  value = import ./emulate-hello-jni {
                    inherit androidenv abiVersion;
                    platformVersion = emulatePlatformVersion;
                    hello_jni = builtins.getAttr "build_${buildPlatformVersion}" (builtins.getAttr "host_${system}" hello_jni_debug);
                  };
                }
              ) abiVersions);
            }
          ) emulatePlatformVersions);
        }
      ) buildPlatformVersions);
    }
  ) systems);

  emulate_hello_jni_release = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = builtins.listToAttrs (map (emulatePlatformVersion:

            { name = "emulate_" + emulatePlatformVersion;
              value = builtins.listToAttrs (map (abiVersion:

                { name = abiVersion;
                  value = import ./emulate-hello-jni {
                    inherit abiVersion androidenv;
                    platformVersion = emulatePlatformVersion;
                    hello_jni = builtins.getAttr "build_${buildPlatformVersion}" (builtins.getAttr "host_${system}" hello_jni_release);
                  };
                }
              ) abiVersions);
            }
          ) emulatePlatformVersions);
        }
      ) buildPlatformVersions);
    }
  ) systems);
}
