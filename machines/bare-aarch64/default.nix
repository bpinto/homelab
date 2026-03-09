{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Import shared configuration
  imports = [
    ../shared.nix
    ../bare-shared.nix
  ];

  # Bare-metal aarch64 specific overrides
  networking.hostName = "nixos";

  # Add bare-metal hardware modules or tuning here.
}
