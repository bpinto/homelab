{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Force Home Manager to manage the config.nu file, even if it already exists.
  # This ensures that any changes to the configuration are applied correctly.
  home.file."${config.programs.nushell.configDir}/config.nu".force = true;

  home.shell.enableNushellIntegration = true;

  programs.bash = {
    enable = true;

    initExtra = ''
      # If we're in an interactive shell, and it's not a dumb terminal, switch to Nushell
      if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
        exec nu
      fi
    '';
  };

  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
    };
  };
}
