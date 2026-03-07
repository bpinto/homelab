{ config, pkgs, lib, sops-nix, home-manager, ... }:

{
  # Import flake modules
  imports = [
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager

    # Import OS configurations
    ../users/hass/nixos.nix

    # Import service configurations
    ../services/homelab-clone.nix
  ];

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hass = import ../users/hass/home-manager.nix;
  };

  # Systemd-boot configuration for UEFI systems
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [ bash coreutils nixfmt ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Garnix binary cache
    settings = {
      substituters = [ "https://cache.garnix.io/" ];
      trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    };
  };

  # SOPS configuration
  sops.age.sshKeyPaths = [ "/etc/ssh/homelab_host" ];
  sops.defaultSopsFile = ./../secrets/nixos.yaml;
  sops.secrets.user_hass_password = { neededForUsers = true; };

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
