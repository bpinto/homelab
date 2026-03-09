{
  config,
  pkgs,
  lib,
  ...
}:

{
  sops.secrets.wifi_iot_password = { };
  sops.secrets.wifi_iot_ssid = { };

  # Enable iwd for Wi‑Fi management
  networking.wireless.iwd = {
    enable = true;

    settings = {
      IPv6 = {
        Enabled = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  # Disable DHCP for all interfaces (systemd-networkd will handle it)
  networking.useDHCP = false;

  # Enable resolved for DNS
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
  };

  # Use systemd-networkd for network management
  systemd.network = {
    enable = true;

    # Configure systemd-networkd-wait-online to succeed when any interface is online
    # This allows boot to proceed once either ethernet or wifi is connected
    wait-online = {
      enable = true;
      anyInterface = true;
    };
  };

  # Ethernet configuration - matches any Ethernet interface
  systemd.network.networks."10-ethernet" = {
    matchConfig.Name = "en*";
    linkConfig.RequiredForOnline = "routable";

    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };

  # WiFi configuration - matches any WiFi interface
  systemd.network.networks."20-wifi" = {
    matchConfig.Name = "wl*";
    linkConfig.RequiredForOnline = "routable";

    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };

  # Connect to WiFi using iwctl command
  systemd.services.iwd-connect = {
    description = "Connect to WiFi using iwctl";
    after = [ "iwd.service" ];
    requires = [ "iwd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = ''
      # Wait for iwd to be ready
      sleep 2

      # Find WiFi interface (matches wl*)
      INTERFACE=$(${pkgs.iproute2}/bin/ip link show | ${pkgs.gnugrep}/bin/grep -oP '^\d+: \Kwl\w+' | head -n1)

      if [ -z "$INTERFACE" ]; then
        echo "No WiFi interface found"
        exit 1
      fi

      SSID=$(cat ${config.sops.secrets.wifi_iot_ssid.path})
      PASSPHRASE=$(cat ${config.sops.secrets.wifi_iot_password.path})

      echo "Connecting to $SSID on interface $INTERFACE"
      ${pkgs.iwd}/bin/iwctl --passphrase "$PASSPHRASE" station "$INTERFACE" connect "$SSID"
    '';
  };

  environment.systemPackages = with pkgs; [
    iwd
  ];
}
