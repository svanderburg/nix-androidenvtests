{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
}:

let
  pkgs = import nixpkgs { inherit system; };
in
rec {
  myfirstapp_debug = import ./myfirstapp {
    inherit (pkgs) androidenv;
    release = false;
  };
  
  myfirstapp_release = import ./myfirstapp {
    inherit (pkgs) androidenv;
    release = true;
  };
  
  emulate_myfirstapp_debug = import ./emulate-myfirstapp {
    inherit (pkgs) androidenv;
    inherit myfirstapp_debug;
  };
  
  emulate_myfirstapp_release = import ./emulate-myfirstapp {
    inherit (pkgs) androidenv;
    inherit myfirstapp_release;
  };
}
