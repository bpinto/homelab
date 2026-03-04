avahi-root-setup:
    sudo systemctl enable --now avahi-daemon.service

    # Open the mDNS port in the firewall
    sudo firewall-cmd --add-port=5353/udp --permanent
    sudo firewall-cmd --reload
