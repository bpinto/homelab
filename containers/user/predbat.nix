{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.predbat = {
    image = "docker.io/nipar44/predbat_addon:slim-v8.34.7";

    environment = {
      TZ = "Europe/Lisbon";
    };

    extraConfig = {
      Container = {
        GroupAdd = "keep-groups";
      };

      Service = {
        ExecStartPre = "${pkgs.writeShellScript "predbat-wait-for-ha" ''
          set -euo pipefail
          while ! ${pkgs.podman}/bin/podman healthcheck run homeassistant; do
            echo "Waiting for homeassistant to be healthy..."
            sleep 2
          done
        ''}";
        ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --service=svc:predbat 127.0.0.1:5052";
        RestartSec = "30";
      };

      Unit = {
        After = [ "podman-homeassistant.service" ];
        StartLimitIntervalSec = "0"; # retry indefinitely
      };
    };

    extraPodmanArgs = [
      "--replace"
      "--rm"
    ];

    ports = [
      "5052:5052"
    ];

    user = "predbat";
    userNS = "keep-id:uid=9005,gid=9005";

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/home/hass/src/homelab/home-assistant/predbat:/config:z"
      "/home/hass/src/homelab/home-assistant/secrets.yaml:/config/secrets.yaml:z"
    ];
  };
}
