{
  config,
  pkgs,
  lib,
  ...
}:

{
  users.users.hass = {
    description = "Home Assistant user";
    extraGroups = [
      "network"
      "wheel"
    ];
    hashedPasswordFile = config.sops.secrets.user_hass_password.path;
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOO9/G6S0q7tMp+UR/Xdrfij/Lbe5CGWDDwu/7W/KET9 sequins33.fuses@icloud.com"
    ];
  };
}
