{ config, pkgs, lib, ... }:

{
  # Systemd service to clone the homelab repository once on bootstrap
  systemd.services.homelab-clone = {
    description = "Clone homelab repository from GitHub (one-time)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    # Only run if the directory doesn't exist
    unitConfig = {
      ConditionPathExists = "!/home/hass/src/homelab";
    };
    
    serviceConfig = {
      Type = "oneshot";
      User = "hass";
      Group = "users";
      WorkingDirectory = "/home/hass";
    };

    script = ''
      REPO_URL="https://github.com/bpinto/homelab"
      REPO_PATH="/home/hass/src/homelab"

      echo "Creating src directory..."
      mkdir -p /home/hass/src

      echo "Cloning homelab repository..."
      ${pkgs.git}/bin/git clone "$REPO_URL" "$REPO_PATH"

      echo "Homelab repository cloned successfully at $(date)"
    '';
  };
}
