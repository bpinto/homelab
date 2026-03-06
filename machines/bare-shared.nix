{ config, pkgs, lib, ... }:

{
  imports = [
    ../services/network.nix
  ];

  # Enable firmware for hardware devices (e.g., Realtek WiFi/network chips)
  hardware.enableAllFirmware = true;

  networking.hostName = "nixos";
}
