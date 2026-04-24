{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.homeassistant = {
    image = "ghcr.io/home-assistant/home-assistant:2026.4.4";

    addCapabilities = [
      "NET_ADMIN"
      "NET_RAW"
    ];

    environment = {
      TZ = "Europe/Lisbon";
    };

    extraConfig = {
      Container = {
        HealthCmd = "curl -f http://127.0.0.1:8123/manifest.json || exit 1";
        HealthInterval = "10s";
        HealthRetries = "5";
        HealthStartPeriod = "30s";
      };

      Service = {
        # Copy secrets from sops-nix into the Home Assistant config directory so HA can manage the file itself
        ExecStartPre = "${pkgs.coreutils}/bin/install -m 600 -D ${config.sops.secrets.home-assistant.path} /home/hass/src/homelab/home-assistant/secrets.yaml";
        ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --service=svc:home-assistant 127.0.0.1:8123";
      };

      Unit = {
        # Wait for sops-nix to be ready before starting the Home Assistant container
        After = [ "sops-nix.service" ];
      };
    };

    extraPodmanArgs = [
      "--replace"
      "--rm"
    ];

    network = [ "host" ];

    volumes = [
      "/home/hass/src/homelab/home-assistant:/config:z"
      "/run/dbus:/run/dbus:ro"
    ];
  };
}
