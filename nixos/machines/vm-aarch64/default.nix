{ config, pkgs, lib, ... }:

{
  # Import shared configuration
  imports = [ ../shared.nix ];

  # VM-aarch64 specific overrides
  networking.hostName = "nixos-vm";

  # Any other VM-only, aarch64-specific modules or tweaks can be added here.
}
