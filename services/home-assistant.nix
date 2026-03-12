{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.firewall.allowedUDPPorts = [
    5540 # Matter
    6666 # Tuya Local
    6667 # Tuya Local
  ];

  networking.firewall.allowedTCPPorts = [
    # HomeKit Bridges (separate instances)
    21063
    21064
  ];
}
