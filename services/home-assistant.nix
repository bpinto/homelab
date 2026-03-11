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
    # HomeKit Bridges (separate instances)
    21063
    21064
  ];
}
