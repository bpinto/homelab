{
  config,
  pkgs,
  lib,
  home-manager,
  sops-nix,
  ...
}:

{
  # Import flake modules
  imports = [
    home-manager.nixosModules.home-manager
    sops-nix.nixosModules.sops

    # Import OS configurations
    ../users/hass/nixos.nix

    # Import services
    ../services/avahi.nix
    ../services/home-assistant.nix
    ../services/homelab-clone.nix
    ../services/tailscale.nix
  ];

  # Systemd-boot configuration for UEFI systems
  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      configurationLimit = 2;
    };
  };

  environment.systemPackages = with pkgs; [
    bash
    coreutils
    ethtool
    ghostty.terminfo
    nixfmt
  ];

  # Enable firmware for hardware devices (e.g., Realtek WiFi/network chips)
  hardware.enableAllFirmware = true;

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;

  # Home Manager configuration
  home-manager = {
    # NixOS system-wide home-manager configuration
    sharedModules = [
      sops-nix.homeManagerModules.sops
    ];

    useGlobalPkgs = true;
    useUserPackages = true;

    # Configure users
    users.hass = import ../users/hass/home-manager.nix;
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Automatically run the nix garbage collector
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Automatically run the nix store optimiser (daily at 3:45am)
    optimise.automatic = true;

    # Garnix binary cache
    settings = {
      substituters = [ "https://cache.garnix.io/" ];
      trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # SOPS configuration
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/homelab_host" ];
    defaultSopsFile = ./../secrets/nixos.yaml;
  };

  system.stateVersion = "25.11";

  time.timeZone = "Europe/Lisbon";

  # Reset users and groups configuration on system activation
  users.mutableUsers = false;
}
