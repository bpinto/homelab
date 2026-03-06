{
  description = "Homelab: NixOS configurations";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # Stable Nixpkgs (use 0.1 for unstable)
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3"; # Determinate 3.*
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    mkSystem = import ./lib/mk-system.nix {
      inherit nixpkgs inputs;
    };
  in {
    # Formatter configuration for `nix fmt`
    formatter = {
      aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };

    nixosConfigurations = {
      bare-aarch64 = mkSystem {
        system = "aarch64-linux";
        modules = [ ./machines/bare-aarch64/default.nix ];
      };

      bare-x86_64 = mkSystem {
        system = "x86_64-linux";
        modules = [ ./machines/bare-x86_64/default.nix ];
      };

      vm-aarch64 = mkSystem {
        system = "aarch64-linux";
        modules = [ ./machines/vm-aarch64/default.nix ];
      };

      vm-x86_64 = mkSystem {
        system = "x86_64-linux";
        modules = [ ./machines/vm-x86_64/default.nix ];
      };
    };
  };
}
