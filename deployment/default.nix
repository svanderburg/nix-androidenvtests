{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" ]
, buildPlatformVersions ? [ "16" ]
, emulatePlatformVersions ? [ "16" ]
, abiVersions ? [ "armeabi-v7a" ]
}:

rec {
  myfirstapp_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./myfirstapp {
            inherit (pkgs) androidenv;
            platformVersion = buildPlatformVersion;
            release = false;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);
  
  myfirstapp_release = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./myfirstapp {
            inherit (pkgs) androidenv;
            platformVersion = buildPlatformVersion;
            release = true;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);
  
  emulate_myfirstapp_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = builtins.listToAttrs (map (emulatePlatformVersion:
      
            { name = "emulate_" + emulatePlatformVersion;
              value = builtins.listToAttrs (map (abiVersion:
        
                { name = abiVersion;
                  value = import ./emulate-myfirstapp {
                    inherit (pkgs) androidenv;
                    inherit abiVersion;
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
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = builtins.listToAttrs (map (emulatePlatformVersion:
      
            { name = "emulate_" + emulatePlatformVersion;
              value = builtins.listToAttrs (map (abiVersion:
        
                { name = abiVersion;
                  value = import ./emulate-myfirstapp {
                    inherit (pkgs) androidenv;
                    inherit abiVersion;
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
