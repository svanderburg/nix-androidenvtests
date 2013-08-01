{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
, buildPlatformVersions ? [ "16" ]
, emulatePlatformVersions ? [ "16" ]
, abiVersions ? [ "armeabi-v7a" ]
}:

let
  pkgs = import nixpkgs { inherit system; };
  
  # Allow strings as parameters by converting them to lists
  _buildPlatformVersions = if builtins.isList buildPlatformVersions then buildPlatformVersions else [ buildPlatformVersions ];
  _emulatePlatformVersions = if builtins.isList emulatePlatformVersions then emulatePlatformVersions else [ emulatePlatformVersions ];
  _abiVersions = if builtins.isList abiVersions then abiVersions else [ abiVersions ];
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
  ) _buildPlatformVersions);
  
  myfirstapp_release = builtins.listToAttrs (map (buildPlatformVersion:
    { name = "build_" + buildPlatformVersion;
      value = import ./myfirstapp {
        inherit (pkgs) androidenv;
        platformVersion = buildPlatformVersion;
        release = true;
      };
    }
  ) _buildPlatformVersions);
  
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
          ) _abiVersions);
        }
      ) _emulatePlatformVersions);
    }
  ) _buildPlatformVersions);
  
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
          ) _abiVersions);
        }
      ) _emulatePlatformVersions);
    }
  ) _buildPlatformVersions);
}
