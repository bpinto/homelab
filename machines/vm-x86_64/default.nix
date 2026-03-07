{ config, pkgs, ... }:

{
  # Import shared configuration
  imports = [
    ../shared.nix
    ../vm-shared.nix
  ];
}
