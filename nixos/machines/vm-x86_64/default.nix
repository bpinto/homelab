{ config, pkgs, lib, ... }:

{
  # Import shared configuration
  imports = [ ../shared.nix ];

  # VM-x86_64 specific overrides
  networking.hostName = "nixos-vm";

  # Any other VM-only, x86_64-specific modules or tweaks can be added here.
}
