{ config, pkgs, lib, ... }:

let
  pubKey = builtins.readFile ./../../secrets/hass.pub;
in
{
  users.users.hass = {
    isNormalUser = true;
    description = "Home Assistant user";
    extraGroups = [ "network" ];
    home = "/home/hass";
    createHome = true;

    openssh.authorizedKeys.keys = [ pubKey ];
  };
}
