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

  # Bare-metal x86_64 specific overrides
  networking.hostName = "nixos";

  # Add bare-metal hardware modules or tuning here.
}
