{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.esphome = {
    image = "docker.io/esphome/esphome:2026.2.4";

    environment = {
      TZ = "Europe/Lisbon";
    };

    extraConfig = {
      Container = {
        GroupAdd = "keep-groups";
      };

      Service = {
        ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --service=svc:esphome 127.0.0.1:6052";
      };

      Unit = {
        # Wait for sops-nix to be ready before starting the ESPHome container
        After = [ "sops-nix.service" ];
      };
    };

    extraPodmanArgs = [
      "--replace"
      "--rm"
    ];

    network = [ "host" ];

    volumes = [
      "/home/hass/src/homelab/esphome:/config:z"
      "/etc/localtime:/etc/localtime:ro"
      "${config.sops.templates.combined-esphome.path}:/config/secrets.yaml:z"
    ];
  };

  sops.secrets.esphome = {
    key = "";
    sopsFile = ./../../secrets/esphome.yaml;
  };

  # Combine Home Assistant and ESPHome secrets into a single file for the ESPHome container
  sops.templates.combined-esphome.content = ''
    ${config.sops.placeholder.home-assistant}
    ${config.sops.placeholder.esphome}
  '';
}
