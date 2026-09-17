{
  config,
  pkgs,
  ...
}:

{
  services.podman.containers.minecraft-bedrock = {
    image = "docker.io/itzg/minecraft-bedrock-server:2026.9.0";

    environment = {
      ALLOW_LIST = "false";
      EULA = "TRUE";
      ONLINE_MODE = "false";
      SERVER_PORT = "19142";
      SERVER_PORTV6 = "19143";
      TZ = "Europe/Lisbon";
    };

    extraPodmanArgs = [
      "--network=host"
      "--replace"
      "--rm"
    ];

    volumes = [
      "/home/hass/src/homelab/minecraft-bedrock:/data:z"
    ];
  };
}
