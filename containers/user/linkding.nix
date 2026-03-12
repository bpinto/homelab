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
      "%t/linkding.env"
    ];

    extraConfig = {
      Container = {
        PublishPort = [ "9090:9090" ];
      };

      Service = {
        # Create environment file from sops secrets
        ExecStartPre = "${pkgs.writeShellScript "linkding-env-setup" ''
          set -euo pipefail
          env_file="$1/linkding.env"
          ${pkgs.coreutils}/bin/install -m 600 /dev/null "$env_file"
          username="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.linkding_username.path})"
          password="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.linkding_password.path})"
          ${pkgs.coreutils}/bin/printf "LD_SUPERUSER_NAME=%s\n" "$username" > "$env_file"
          ${pkgs.coreutils}/bin/printf "LD_SUPERUSER_PASSWORD=%s\n" "$password" >> "$env_file"
        ''} %t";
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

  sops.secrets.linkding_username = { };
  sops.secrets.linkding_password = { };
}
