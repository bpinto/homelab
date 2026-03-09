{ config, pkgs, ... }:

# Tailscale configuration for secure remote access to your homelab.
#
# To authenticate with Tailscale, the following steps are required after the system boots:
#
# Obtain an authentication key from the Tailscale admin console (https://login.tailscale.com/admin/settings/keys).
# sudo tailscale up --auth-key={{ AUTH_TOKEN }} --advertise-exit-node
#
# Allow the Tailscale client to be managed by the "hass" user:
# sudo tailscale set --operator=hass
{
  # Enable nftables for modern firewall management
  networking.nftables.enable = true;

  # Firewall configuration for Tailscale
  networking.firewall = {
    enable = true;

    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Enable systemd-resolved for DNS resolution
  services.resolved.enable = true;

  # Enable tailscale. We manually authenticate when we want with "sudo tailscale up".
  services.tailscale = {
    enable = true;

    # Enables settings required for Tailscale’s routing features like subnet routers and exit nodes.
    useRoutingFeatures = "server";
  };

  # Optimize the performance of subnet routers and exit nodes
  systemd.services.tailscale-udp-gro-forwarding = {
    description = "Enable UDP GRO forwarding for Tailscale performance";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
    };

    script = ''
      DEFAULT_IFACE=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 2>/dev/null | ${pkgs.coreutils}/bin/cut -f 5 -d " " || true)
      if [ -n "$DEFAULT_IFACE" ]; then
        ${pkgs.ethtool}/bin/ethtool -K "$DEFAULT_IFACE" rx-udp-gro-forwarding on rx-gro-list off
        echo "Applied UDP GRO forwarding settings to $DEFAULT_IFACE"
      else
        echo "Warning: Could not determine default network interface"
        exit 1
      fi
    '';
  };

  # Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];
}
