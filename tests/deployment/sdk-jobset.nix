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
  # Android SDK composition
  android_composition = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = system;
      value = import ./android-composition {
        inherit androidenv;
      };
    }
  ) systems);

  # myfirstapp jobs

  myfirstapp_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./myfirstapp {
            inherit androidenv;
            platformVersion = buildPlatformVersion;
            release = false;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);

  myfirstapp_release = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system config; };
      androidenv = getAndroidEnv pkgs;
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./myfirstapp {
            inherit androidenv;
            platformVersion = buildPlatformVersion;
            release = true;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);

  emulate_myfirstapp_debug = builtins.listToAttrs (map (system:
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
                  value = import ./emulate-myfirstapp {
                    inherit androidenv abiVersion;
                    platformVersion = emulatePlatformVersion;
                    myfirstapp = builtins.getAttr "build_${buildPlatformVersion}" (builtins.getAttr "host_${system}" myfirstapp_debug);
                  };
                }
              ) abiVersions);
            }
          ) emulatePlatformVersions);
        }
      ) buildPlatformVersions);
    }
  ) systems);

  emulate_myfirstapp_release = builtins.listToAttrs (map (system:
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
                  value = import ./emulate-myfirstapp {
                    inherit abiVersion androidenv;
                    platformVersion = emulatePlatformVersion;
                    myfirstapp = builtins.getAttr "build_${buildPlatformVersion}" (builtins.getAttr "host_${system}" myfirstapp_release);
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
