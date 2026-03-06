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
}
