{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.miniflux = {
    enable = true;

    adminCredentialsFile = config.sops.secrets."miniflux/env".path;
  };

  systemd.services.miniflux = {
    after = [ "sops-nix.service" ];
  };

  systemd.services.miniflux-tailscale = {
    description = "Configure Tailscale for Miniflux";
    wantedBy = [ "multi-user.target" ];
    after = [
      "miniflux.service"
      "tailscaled.service"
    ];
    requires = [ "miniflux.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --service=svc:miniflux 127.0.0.1:8080";
    };
  };

  sops.secrets."miniflux/env" = { };
}
