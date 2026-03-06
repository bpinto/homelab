{ config, pkgs, lib, ... }:

{
  # Import per-user system config
  imports = [
    ../users/hass/nixos.nix
    ../users/root/nixos.nix
  ];

  # Systemd-boot configuration for UEFI systems
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [ bash coreutils nixfmt ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  system.stateVersion = "25.11";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
