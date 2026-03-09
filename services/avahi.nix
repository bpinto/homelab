{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable Avahi for mDNS/.local domain resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable IPv4 mDNS in NSS
    nssmdns6 = true; # Enable IPv6 mDNS in NSS

    # Don't publish/advertise this machine (we only need to resolve other devices)
    publish.enable = false;
  };

  # Configure systemd-resolved to cooperate with Avahi
  services.resolved = {
    extraConfig = ''
      # Resolved in a listen-only/fallback mode
      MulticastDNS=resolve
    '';

    # Disable LLMNR (not needed for mDNS/Avahi and can be a security risk)
    llmnr = "false";
  };

  # Open firewall for mDNS (UDP port 5353)
  networking.firewall.allowedUDPPorts = [ 5353 ];
}
