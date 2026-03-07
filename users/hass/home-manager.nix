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

  programs.neovim = {
    defaultEditor = true;
    enable = true;
  };

  home.packages = with pkgs; [
    git
    htop
    ripgrep
    tree
  ];
}
