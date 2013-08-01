{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
, buildPlatformVersion ? "16"
, emulatePlatformVersion ? "16"
, abiVersion ? "armeabi-v7a"
}:

let
  pkgs = import nixpkgs { inherit system; };
in
rec {
  myfirstapp_debug = import ./myfirstapp {
    inherit (pkgs) androidenv;
    platformVersion = buildPlatformVersion;
    release = false;
  };
  
  myfirstapp_release = import ./myfirstapp {
    inherit (pkgs) androidenv;
    platformVersion = buildPlatformVersion;
    release = true;
  };
  
  emulate_myfirstapp_debug = import ./emulate-myfirstapp {
    inherit (pkgs) androidenv;
    inherit abiVersion;
    platformVersion = emulatePlatformVersion;
    myfirstapp = myfirstapp_debug;
  };
  
  emulate_myfirstapp_release = import ./emulate-myfirstapp {
    inherit (pkgs) androidenv;
    inherit abiVersion;
    platformVersion = emulatePlatformVersion;
    myfirstapp = myfirstapp_release;
  };
}
