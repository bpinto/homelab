{
  description = "Homelab: NixOS configurations";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # NixOS profiles to optimize settings for different hardware.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # home-manager module for user environment management
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix module to handle encrypted secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nixos-hardware,
      sops-nix,
      ...
    }:
    {
      # Formatter configuration for `nix fmt`
      formatter = {
        aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };

      nixosConfigurations = {
        bmax = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit home-manager nixos-hardware sops-nix; };
          modules = [ ./machines/bmax.nix ];
        };

        vm-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit home-manager sops-nix; };
          modules = [ ./machines/vm-aarch64/default.nix ];
        };

        vm-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit home-manager sops-nix; };
          modules = [ ./machines/vm-x86_64/default.nix ];
        };
      };
    };
}
