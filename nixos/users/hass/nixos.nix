{ config, pkgs, lib, ... }:

let
  pubKey = builtins.readFile ./../../secrets/hass.pub;
in
{
  users.users.hass = {
    description = "Home Assistant user";
    extraGroups = [ "network" "wheel" ];
    hashedPasswordFile = "/nix-config/secrets/hass.password";
    isNormalUser = true;

    openssh.authorizedKeys.keys = [ pubKey ];
  };
}
