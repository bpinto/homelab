{ config, pkgs, lib, ... }:

{
  imports = [
    ../services/network.nix
  ];

  # Enable firmware for hardware devices (e.g., Realtek WiFi/network chips)
  hardware.enableAllFirmware = true;

  networking.hostName = "nixos";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
