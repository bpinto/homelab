tailscale-root-setup AUTH_TOKEN:
    sudo systemctl enable --now tailscaled.service

    # Expose web servers to the Tailscale network by adding the
    # HTTP and HTTPS services to the DMZ zone.
    sudo firewall-cmd --add-service=http --zone=dmz
    sudo firewall-cmd --add-service=https --zone=dmz

    # Add the Tailscale interface to the DMZ zone to allow incoming
    # connections from the Tailscale network.
    sudo firewall-cmd --add-interface=tailscale0 --zone=dmz

    # Make the firewall changes permanent so they persist across reboots.
    sudo firewall-cmd --runtime-to-permanent

    # Run the Tailscale client with the provided authentication key and
    # advertise this node as an exit node on the Tailscale network.
    sudo tailscale up --auth-key={{ AUTH_TOKEN }} --advertise-exit-node
