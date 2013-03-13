{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
}:

let
  pkgs = import nixpkgs { inherit system; };
in
rec {
  myfirstapp = import ./myfirstapp {
    inherit (pkgs) androidenv;
  };
  
  emulate_myfirstapp = import ./emulate-myfirstapp {
    inherit (pkgs) androidenv;
    inherit myfirstapp;
  };
}
