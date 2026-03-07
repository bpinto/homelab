{
  config,
  pkgs,
  lib,
  ...
}:

{
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

  home.packages = with pkgs; [
    htop
    ripgrep
    tree
  ];
}
