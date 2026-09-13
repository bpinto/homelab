{
  config,
  pkgs,
  ...
}:

let
  customServers = pkgs.writeText "bedrock-connect-servers.json" (
    builtins.toJSON [
      {
        name = "Home Server";
        address = "192.168.68.68";
        port = 19142;
      }
    ]
  );
in
{
  services.podman.containers.bedrock-connect = {
    image = "docker.io/pugmatt/bedrock-connect:1.70.0";

    environment = {
      BC_CUSTOM_SERVERS = "/data/custom_servers.json";
    };

    extraPodmanArgs = [
      "--network=host"
      "--replace"
      "--rm"
    ];

    volumes = [
      "${customServers}:/data/custom_servers.json:ro"
    ];
  };
}
