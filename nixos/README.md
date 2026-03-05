# NixOS Configuration

This directory contains the NixOS configuration for homelab infrastructure, designed to run in two environments:

- **VM**: Testing environment on macOS host (VMware Fusion) - validates configuration before bare metal deployment
- **Bare Metal**: Production homelab server on physical hardware

## Setup (VM)

### Prerequisites

- VMware Fusion
- [Determinate Systems NixOS ISO](https://github.com/DeterminateSystems/nixos-iso)
- This repository cloned on your macOS host

### Create the VM

Create a new VMware Fusion VM with these settings:

**Basic Configuration**:

- **Disk**: SATA, 50 GB minimum (adjust based on your homelab needs)
- **CPU/Memory**: 2-4 cores, 4-8 GB RAM (adjust based on services you'll run)
- **Network**: Shared with Mac
- **Boot Mode**: UEFI

### Initial Bootstrap

Boot the VM from the NixOS ISO and open the graphical console.

**1. Set root password**:

```bash
sudo su
passwd
# Set password to: root
```

**2. Verify disk device**:

```bash
ls /dev/sda
```

This should exist if you configured SATA correctly. If you see `/dev/nvme` or `/dev/vda` instead, you'll need to modify the `vm/bootstrap0` Makefile task to use the correct device paths.

**3. Take a snapshot** (optional but recommended):
Create a VM snapshot called "prebootstrap0" - useful if you need to retry.

**4. Get VM IP address**:

```bash
hostname -I
```

Note the IP address (likely `192.168.58.XXX`).

**5. On your macOS host**, open a terminal in this repository and set environment variables:

```bash
cd /path/to/homelab/nixos

# Set VM IP address
export NIXADDR=192.168.58.XXX

# For Apple Silicon (M1/M2/M3/etc):
export NIXNAME=vm-aarch64

# For Intel Macs:
export NIXNAME=vm-intel
```

**6. Run initial bootstrap**:

```bash
make vm/bootstrap0
```

This will:

- Partition the VM disk
- Install a minimal NixOS
- Enable SSH access
- Reboot the VM

**7. After reboot, finalize the setup**:

```bash
make vm/bootstrap
```

This will:

- Copy the full NixOS configuration to the VM
- Apply all customizations
- Copy SSH keys and GPG keyring (optional)
- Reboot into the fully configured system

### Post-Setup

After the final reboot, you should have a fully functional NixOS server VM.

**SSH into the VM**:

```bash
ssh bpinto@<VM-IP>
```

**Testing Configuration Changes**:

1. Modify configuration files in the VM
2. Run `make test` to test without activating
3. Run `make switch` to apply changes
4. Once validated in VM, deploy the same config to bare metal

**Accessing Services**: Services running in the VM will be accessible at the VM's IP address on their respective ports.

## Making Changes

Once the VM is running:

**Inside the VM** (recommended workflow):

```bash
cd /path/to/homelab/nixos

# Test changes without activating
make test

# Apply changes
make switch

# Format code
nix fmt

# Update dependencies
nix flake update
```

**From macOS host** (if you modify files on the host):

```bash
# Copy changes to VM
make vm/copy

# Apply in VM
make vm/switch
```

## Configuration Structure

See [AGENTS.md](./AGENTS.md) for detailed structure and development guidelines.

```
nixos/
├── flake.nix              # Entry point - all machine definitions
├── flake.lock             # Locked dependencies
├── lib/
│   └── mksystem.nix       # Machine builder abstraction
├── machines/
│   ├── shared.nix         # Configuration shared by all machines
│   ├── vm/                # VM-specific configuration
│   └── bare/              # Bare metal configuration
├── modules/
│   ├── services/          # Service modules (tailscale, docker, etc.)
│   └── ...
├── users/
│   └── <username>/        # Per-user system and home-manager configs
└── ...
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config) - Inspiration for this setup
- [the-nix-way/nome](https://github.com/the-nix-way/nome) - Inspiration for this setup
