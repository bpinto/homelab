{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.hostName = "nixos-vm";
  networking.nameservers = [
    "1.1.1.1" # Cloudflare DNS
    "9.9.9.9" # Quad9 DNS (security-focused)
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
