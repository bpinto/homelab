{ nixpkgs, inputs }:

{ system, modules ? [] }:

let
  pkgs = import nixpkgs { inherit system; };
in nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [
    inputs.determinate.nixosModules.default
  ] ++ modules;
}
