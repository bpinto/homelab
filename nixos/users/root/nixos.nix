{ config, pkgs, lib, ... }:

let
  pubKey = builtins.readFile ./../../secrets/root.pub;
in
{
  users.users.root = {
    openssh.authorizedKeys.keys = [ pubKey ];
  };
}
