{
  config,
  pkgs,
  lib,
  ...
}:

# Tailscale DNS integration:
# Add AdGuard Home's Tailscale IP as a Global Nameserver (https://login.tailscale.com/admin/dns).
{
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 53;

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  networking.nameservers = [ "127.0.0.1" ];
}
