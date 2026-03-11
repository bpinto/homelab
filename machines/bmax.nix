{
  config,
  pkgs,
  lib,
  nixos-hardware,
  ...
}:

{
  # Import shared configuration
  imports = [
    nixos-hardware.nixosModules.gmktec-nucbox-g3-plus
    ./bare-x86_64/default.nix
  ];

  # Add bmax hardware modules or tuning here.
}
