# NixOS Configuration - Agent Instructions

## Project Context

This directory contains the homelab NixOS configurations (VMs for testing and bare-metal for production). Work in this directory only when the task targets NixOS configuration; refer to ../AGENTS.md for repository-wide policies.

## Inspiration Repositories (Local Access)

- https://github.com/mitchellh/nixos-config — module/user separation patterns
- https://github.com/the-nix-way/nome — FlakeHub/overlay patterns and home-manager integration

Read those for reference, but follow the local conventions below.

## Architecture

Core principle: a modular, flake-based configuration that shares the majority of code between VM and bare-metal machines.

Structure (important files and layout):

```
nixos/
├── flake.nix              # Flake entrypoint; defines nixosConfigurations keys
├── flake.lock             # Commit this
├── lib/                   # helper functions (mk-system.nix)
├── machines/
│   ├── shared.nix         # Shared config imported by machine outputs
│   ├── vm-aarch64/        # VM aarch64 specific files
│   ├── vm-x86_64/         # VM x86_64 specific files
│   ├── bare-aarch64/      # Bare metal aarch64 specific files
│   └── bare-x86_64/       # Bare metal x86_64 specific files
├── modules/               # service, hardware, virtualization modules
├── overlays/              # package overlays
├── users/                 # per-user system + home-manager fragments
├── secrets/               # public keys and secret-management helpers (.gitignored)
└── Makefile               # helper targets for VM bootstrapping, copy, switch, etc.
```

Note: flake.nix exposes nixosConfigurations with keys: bare-aarch64, bare-x86_64, vm-aarch64, vm-x86_64. Use those names when referencing outputs.

## Important Patterns

- The project uses a small mk-system helper (lib/mk-system.nix) to import nixpkgs and produce the nixosConfigurations via pkgs.lib.nixosSystem. See lib/mk-system.nix.
- Namespace service options under a project-specific prefix (e.g., services.homelab.*) to avoid collisions.
- Keep machine-specific overrides in the machine directories (vm-*/ bare-*); put shared configuration in machines/shared.nix.
- Keep user-level system entries in users/<name>/nixos.nix and the corresponding home-manager config in users/<name>/home.nix.

## Secrets

- The secrets/ directory contains public keys and examples; private material must never be committed. Follow existing patterns (agenix/sops or other external secret fetch) when adding secrets locally.

## Build & Operations (preferred workflows)

This repo provides a Makefile with convenient targets. Preferred approach is to use those targets rather than hand-writing long nixos-rebuild commands.

Key Makefile targets and usage:

- VM bootstrap (host -> VM iso install):
  - NIXADDR=<VM_IP> make vm/bootstrap0   # partition, format, install minimal NixOS (root password set)
  - NIXADDR=<VM_IP> make vm/bootstrap    # copy config and apply full configuration

- VM management (from host):
  - NIXADDR=<VM_IP> make vm/copy         # rsync repository into VM (/nix-config)
  - NIXADDR=<VM_IP> make vm/switch       # run nixos-rebuild on VM using the copied config

- Local operations (run inside VM or on bare metal):
  - make switch          # apply configuration (uses NIXNAME variable)
  - make test            # run nixos-rebuild test

Makefile variables:
- NIXADDR: remote VM address for vm/* targets
- NIXPORT: SSH port (default 22)
- NIXUSER: user to connect as when copying/applying (default hass)
- NIXNAME: the nixosConfigurations key to operate on (default in Makefile: vm-aarch64)

Examples:
- Build/check flake locally: nix flake check
- Build a configuration derivation (example): nix build .#nixosConfigurations.vm-aarch64.config.system.build.toplevel
- Apply inside target machine (from within that machine): sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#vm-aarch64

The Makefile also includes safe helpers for partitioning, formatting and mounting an attached VM disk (vm/partition, vm/format, vm/mount). Read Makefile for exact semantics and required env vars.

## Conventions & Validation

- Use Conventional Commits for changes: e.g., feat(nixos): add tailscale module
- Run nix flake check and nix fmt where applicable
- Test in VM build before applying to bare metal
- Avoid committing secrets; check .gitignore before committing

## Typical Services & Modules

Common services configured here include Tailscale, container runtimes (Docker/Podman), storage services, monitoring (Prometheus/Grafana) and reverse proxies (Traefik/Caddy). Add service modules under modules/services/ following the local module pattern.

## When Writing Code

- Inspect lib/mk-system.nix and flake.nix to understand how outputs are composed
- Follow the module pattern for services and expose an enable option
- Keep changes minimal and document how to validate them (nix flake check, nix build, Makefile targets)

## Testing

After changes:
- nix flake check
- nix build .#nixosConfigurations.<target>.config.system.build.toplevel (replace <target> with vm-aarch64, vm-x86_64, etc.)
- Use Makefile targets (make test / make switch) for applying or testing on the machine

## Common Tasks

- New service module: create modules/services/<name>.nix, import/use it in machine modules and expose an option
- New machine: add a directory under machines/ and add an entry to flake.nix's nixosConfigurations
- Secrets: add only examples here; use an external secret manager to provision at deploy time

---

This file documents repository conventions and the operational workflow for the NixOS configuration. If you need a machine-specific clarification, read the machine directory's files and the Makefile before changing anything.
