{ config, pkgs, lib, ... }:

{
  # Import per-user system config
  imports = [
    ../users/hass/nixos.nix
  ];

  # Systemd-boot configuration for UEFI systems
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [ bash coreutils nixfmt ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";

  # Reset users and groups configuration on system activation
  users.mutableUsers = false;
}
