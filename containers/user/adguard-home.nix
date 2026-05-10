{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.adguard-home = {
    image = "adguard/adguardhome:v0.107.74";

    environment = {
      TZ = "Europe/Lisbon";
    };

    extraConfig = {
      Container = {
        HealthCmd = "wget -qO- http://127.0.0.1:3000/ || exit 1";
        HealthInterval = "10s";
        HealthRetries = "5";
        HealthStartPeriod = "30s";
      };

      Service = {
        ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --service=svc:adguard-home 127.0.0.1:3000";
      };
    };

    extraPodmanArgs = [
      "--replace"
      "--rm"
    ];

    ports = [
      "53:53/tcp"
      "53:53/udp"
      "3000:3000/tcp"
    ];

    volumes = [
      "/home/hass/src/homelab/adguard-home/work:/opt/adguardhome/work:z"
      "/home/hass/src/homelab/adguard-home/conf:/opt/adguardhome/conf:z"
    ];
  };
}
