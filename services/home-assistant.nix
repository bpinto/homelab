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

  networking.firewall.allowedTCPPorts = [
    21063 # HomeKit Bridge
  ];
}
