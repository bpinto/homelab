{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.matter-server = {
    image = "ghcr.io/matter-js/python-matter-server:8.1.2";

    environment = {
      TZ = "Europe/Lisbon";
    };

    exec = "--storage-path /data --paa-root-cert-dir /data/credentials --bluetooth-adapter 0";

    extraConfig = {
      Service = {
        ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --service=svc:matter-server --tcp 5580 127.0.0.1:5580";
      };
    };

    extraPodmanArgs = [
      "--replace"
      "--rm"
      "--security-opt apparmor=unconfined"
    ];

    network = [ "host" ];

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/home/hass/src/homelab/home-assistant/matter-server:/data:z"
      "/run/dbus:/run/dbus:ro"
    ];
  };
}
