{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.firewall.allowedUDPPorts = [
    # Tuya Local integration
    6666
    6667
  ];
}
