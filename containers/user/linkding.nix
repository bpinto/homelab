{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.linkding = {
    image = "ghcr.io/sissbruecker/linkding:1.45.0";

    environment = {
      TZ = "Europe/Lisbon";
    };

    environmentFile = [
      config.sops.secrets."linkding/env".path
    ];

    extraConfig = {
      Container = {
        PublishPort = [ "9090:9090" ];
      };

      Service = {
        ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --service=svc:linkding 127.0.0.1:9090";
      };

      Unit = {
        After = [ "sops-nix.service" ];
      };
    };

    extraPodmanArgs = [
      "--replace"
      "--rm"
    ];

    volumes = [
      "/home/hass/src/homelab/linkding:/etc/linkding/data:z"
    ];
  };

  sops.secrets."linkding/env" = { };
}
