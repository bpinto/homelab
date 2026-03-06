{ nixpkgs }:

{ system, modules ? [] }:

let
  pkgs = import nixpkgs { inherit system; };
in pkgs.lib.nixosSystem {
  inherit system;

  modules = modules;
}
