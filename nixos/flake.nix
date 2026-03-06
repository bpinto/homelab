{
  description = "Homelab: NixOS configurations";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    mkSystem = import ./lib/mk-system.nix {
      inherit nixpkgs;
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
