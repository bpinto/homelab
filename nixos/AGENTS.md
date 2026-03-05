# NixOS Configuration - Agent Instructions

## Project Context

Part of homelab multi-project repo. NixOS config for **homelab server infrastructure**: VM (testing on macOS) and bare metal (production). This is **not a development environment** - it's for running homelab services (containers, storage, networking, etc.). Keep all NixOS work in `nixos/`. See `../AGENTS.md` for repo-wide rules.

## Inspiration Repositories (Local Access)

- **https://github.com/mitchellh/nixos-config**: Study `lib/mksystem.nix`, machine/user separation, module patterns
- **https://github.com/the-nix-way/nome**: FlakeHub inputs, overlay patterns, home-manager integration

Read these repos when implementing similar patterns.

## Architecture

**Core Principle**: Modular, flake-based config with 95% shared between VM (testing) and bare metal (production homelab server).

**Server Focus**: Headless operation, service hosting, remote management. No desktop environment.

**Structure**:

```
nixos/
├── flake.nix              # Entry point - all machine definitions
├── flake.lock             # Commit this
├── lib/
│   └── mksystem.nix       # Machine builder (like mitchellh's)
├── machines/
│   ├── shared.nix         # Config for ALL machines (90% of code)
│   ├── vm/
│   │   ├── default.nix    # VM-specific imports + overrides
│   │   └── hardware.nix   # VM hardware config
│   └── bare/
│       ├── default.nix    # Bare metal imports + overrides
│       └── hardware.nix   # Real hardware config
├── modules/
│   ├── services/          # Service modules (tailscale, docker, etc.)
│   ├── virtualization/    # VM-specific modules
│   └── hardware/          # Bare metal hardware modules
├── users/
│   └── <username>/
│       ├── nixos.nix      # User account (system level)
│       └── home.nix       # Home-manager config (user env)
├── overlays/
│   └── default.nix        # Package overlays
├── secrets/
│   ├── .gitignore         # Exclude secret files
│   └── secrets.nix        # agenix/sops config (no actual secrets)
└── scripts/               # Helper scripts for deploy/build
```

## Key Patterns

### Machine Builder (lib/mksystem.nix)

Pattern from mitchellh - abstracts boilerplate. Takes machine name + config, returns nixosSystem.

### Module Pattern

```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.homelab.myservice;
in {
  options.services.homelab.myservice = {
    enable = mkEnableOption "description";
  };
  config = mkIf cfg.enable { ... };
}
```

### Imports

- `machines/vm/default.nix` imports `../shared.nix` + modules
- `machines/shared.nix` has config for ALL machines
- Machine-specific files only contain overrides/additions

### User Config Separation

- `users/<name>/nixos.nix`: System-level user account
- `users/<name>/home.nix`: Home-manager user environment

## Conventions

1. **Namespace modules**: `services.homelab.*` not `services.*` (avoid conflicts)
2. **FlakeHub inputs**: Use `https://flakehub.com/f/...` URLs (like nome)
3. **Conventional commits**: Required (see ../AGENTS.md)
4. **No secrets in repo**: Use agenix or external fetch
5. **Test in VM first**: Always build VM before bare metal
6. **Use lib.mkDefault**: For values machines might override

## Implementation Order

1. **Foundation**: flake.nix → lib/mksystem.nix → machines/shared.nix → VM config → user configs
2. **Services**: Add modules/services/\* as needed (tailscale, docker, etc.)
3. **Advanced**: overlays, secrets management
4. **Bare Metal**: Replicate VM pattern with hardware-specific tweaks

## Quick Reference

**Build VM**: `nix build .#nixosConfigurations.vm.config.system.build.toplevel`
**Check**: `nix flake check`
**Deploy**: `sudo nixos-rebuild switch --flake .#vm` (from inside VM)
**Format**: `nix fmt`
**Update**: `nix flake update`

## Environment Details

- VM: aarch64-linux or x86_64-linux (specify in flake.nix)
- Bare: x86_64-linux (adjust as needed)
- User: Set username in flake.nix constants

**Typical Homelab Services**:

- Tailscale (VPN/mesh networking)
- Docker/Podman (container runtime)
- Storage services (NFS, Samba)
- Media services (Plex, Jellyfin - if desired)
- Monitoring (Prometheus, Grafana)
- Reverse proxy (Traefik, Caddy)

## When Writing Code

1. Check ~/src/nixos-config or ~/src/nome for similar patterns first
2. Follow the module pattern for all services
3. Put shared config in machines/shared.nix
4. Put machine-specific overrides in machines/{vm,bare}/default.nix
5. Use descriptive commit messages: `feat(nixos): add docker module`

## Common Tasks

**New service module**: Create in `modules/services/`, import in machine config, enable with option
**New machine**: Create dir in `machines/`, add to flake.nix outputs
**Update package**: Add to overlay or use unstable input
**Secrets**: Use agenix pattern from mitchellh's repo
**Deploy to bare metal**: After testing in VM, apply same config to physical hardware

## Testing

After any change:

```bash
nix flake check           # Syntax/structure
nix build .#nixosConfigurations.vm.config.system.build.toplevel  # VM builds
# If both pass, ready to deploy
```
