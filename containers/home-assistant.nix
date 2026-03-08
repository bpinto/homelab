{
  config,
  pkgs,
  ...
}:

{
  virtualisation.oci-containers = {
    backend = "podman";

    containers.homeassistant = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant:2026.3.0";

      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };

      environment = {
        TZ = "Europe/Lisbon";
      };

      extraOptions = [
        "--detach"
        "--health-cmd=curl -f http://127.0.0.1:8123/manifest.json || exit 1"
        "--health-interval=10s"
        "--health-retries=5"
        "--health-start-period=30s"
        "--name=homeassistant"
        "--replace"
        "--rm"
        "--userns=keep-id"
      ];

      networks = [ "host" ];

      podman = {
        sdnotify = "healthy";
        user = "hass";
      };

      volumes = [
        "/home/hass/src/homelab/home-assistant:/config:z"
        "/run/dbus:/run/dbus:ro"
      ];
    };
  };

  systemd.user.services."container-homeassistant-tailscale" = {
    enable = true;
    description = "Home Assistant tailscale serve";
    wants = [ "container-homeassistant.service" ];
    after = [ "container-homeassistant.service" ];
    serviceConfig = {
      Type = "simple";
      # Wait for the container to report a healthy status via podman
      ExecStartPre = ''/bin/sh -c 'for i in $(seq 1 60); do status=$(${pkgs.podman}/bin/podman inspect --format "{{.State.Health.Status}}" homeassistant 2>/dev/null) || status=unknown; [ "$status" = "healthy" ] && exit 0; sleep 1; done; exit 1' '';
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --service=svc:home-assistant 127.0.0.1:8123";
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStartSec = 120;
    };
    wantedBy = [ "default.target" ];
  };
}
