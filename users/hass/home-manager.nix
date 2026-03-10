{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./nushell.nix

    # Import containers
    ../../containers/user/esphome.nix
    ../../containers/user/home-assistant.nix
    ../../containers/user/matter-server.nix
    ../../containers/user/predbat.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";

  programs.git = {
    enable = true;

    settings = {
      alias = {
        amend = "commit --amend -C HEAD";
        co = "checkout";
        ds = "diff --staged";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        pf = "push --force-with-lease";
        pr = "pull --rebase";
        st = "status";
      };

      user = {
        name = "Homelab";
        email = "homelab@bpinto.com";
      };
    };
  };

  programs.neovim = {
    defaultEditor = true;
    enable = true;
  };

  services.podman.enable = true;

  # SOPS configuration
  sops = {
    age.sshKeyPaths = [ "/home/hass/.ssh/homelab_host" ];
    defaultSopsFile = ./../../secrets/nixos.yaml;
  };

  # Used by multiple containers
  sops.secrets.home-assistant = {
    key = "";
    sopsFile = ./../../secrets/home-assistant.yaml;
  };

  home.packages = with pkgs; [
    htop
    ripgrep
    tree
  ];
}
