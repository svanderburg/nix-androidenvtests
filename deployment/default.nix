{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
, buildPlatformVersions ? [ "16" ]
, emulatePlatformVersions ? [ "16" ]
, abiVersions ? [ "armeabi-v7a" ]
}:

let
  pkgs = import nixpkgs { inherit system; };
in
rec {
  myfirstapp_debug = builtins.listToAttrs (map (buildPlatformVersion:
    { name = "build_" + buildPlatformVersion;
      value = import ./myfirstapp {
        inherit (pkgs) androidenv;
        platformVersion = buildPlatformVersion;
        release = false;
      };
    }
  ) buildPlatformVersions);
  
  myfirstapp_release = builtins.listToAttrs (map (buildPlatformVersion:
    { name = "build_" + buildPlatformVersion;
      value = import ./myfirstapp {
        inherit (pkgs) androidenv;
        platformVersion = buildPlatformVersion;
        release = true;
      };
    }
  ) buildPlatformVersions);
  
  emulate_myfirstapp_debug = builtins.listToAttrs (map (buildPlatformVersion:
    { name = "build_" + buildPlatformVersion;
      value = builtins.listToAttrs (map (emulatePlatformVersion:
      
        { name = "emulate_" + emulatePlatformVersion;
          value = builtins.listToAttrs (map (abiVersion:
        
            { name = abiVersion;
              value = import ./emulate-myfirstapp {
                inherit (pkgs) androidenv;
                inherit abiVersion;
                platformVersion = emulatePlatformVersion;
                myfirstapp = builtins.getAttr "build_${buildPlatformVersion}" myfirstapp_debug;
              };
            }
          ) abiVersions);
        }
      ) emulatePlatformVersions);
    }
  ) buildPlatformVersions);
  
  emulate_myfirstapp_release = builtins.listToAttrs (map (buildPlatformVersion:
    { name = "build_" + buildPlatformVersion;
      value = builtins.listToAttrs (map (emulatePlatformVersion:
      
        { name = "emulate_" + emulatePlatformVersion;
          value = builtins.listToAttrs (map (abiVersion:
        
            { name = abiVersion;
              value = import ./emulate-myfirstapp {
                inherit (pkgs) androidenv;
                inherit abiVersion;
                platformVersion = emulatePlatformVersion;
                myfirstapp = builtins.getAttr "build_${buildPlatformVersion}" myfirstapp_release;
              };
            }
          ) abiVersions);
        }
      ) emulatePlatformVersions);
    }
  ) buildPlatformVersions);
}
