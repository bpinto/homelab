# Homelab NixOS Configuration Makefile

# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= hass

# The name of the nixosConfiguration in the flake
NIXNAME ?= vm-aarch64 # Options: bare-aarch64, bare-x86_64, vm-aarch64, vm-x86_64

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options for VM access (bootstrap-focused)
SSH_OPTIONS=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Disk configuration
DISK      ?= /dev/sda
BOOT_SIZE ?= 512MiB
SWAP_SIZE ?= 8GiB

# Partition labels
BOOT_LABEL := boot
SWAP_LABEL := swap
ROOT_LABEL := nixos

# Partition paths (by-label for reliability)
BOOT_PART := /dev/disk/by-label/$(BOOT_LABEL)
SWAP_PART := /dev/disk/by-label/$(SWAP_LABEL)
ROOT_PART := /dev/disk/by-label/$(ROOT_LABEL)

# Derive partition prefix: /dev/sda -> /dev/sda, /dev/nvme0n1 -> /dev/nvme0n1p
PART_PREFIX := $(shell echo $(DISK) | grep -q 'nvme\|mmcblk' && echo "$(DISK)p" || echo "$(DISK)")

.PHONY: help switch test vm/format vm/partition vm/mount vm/secrets vm/switch

help: ## Show this help message
	@echo "Homelab NixOS Configuration"
	@echo ""
	@echo "VM Bootstrap (run from macOS host):"
	@echo "  make vm/bootstrap0   - Initial VM setup (partition, minimal install)"
	@echo "  make vm/bootstrap    - Finalize VM with full configuration"
	@echo ""
	@echo "VM Management (run from macOS host):"
	@echo "  make vm/copy         - Copy config files to VM"
	@echo "  make vm/switch       - Apply configuration in VM"
	@echo ""
	@echo "Local Operations (run inside VM or on bare metal):"
	@echo "  make switch          - Apply configuration changes"
	@echo "  make test            - Test configuration without activating"
	@echo ""
	@echo "Required variables for VM operations:"
	@echo "  NIXADDR=<VM IP>      - VM IP address (e.g., 192.168.58.130)"
	@echo "  NIXNAME=<config>     - Configuration name (default: bare)"

switch: ## Apply configuration (run inside VM or bare metal)
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#$(NIXNAME)"

test: ## Test configuration without activating
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIXNAME)"

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and the root password set to "root". This will install NixOS.
vm/partition:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/partition"; \
		exit 1; \
	fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		sgdisk --zap-all $(DISK); \
		sgdisk \
			--new=1:0:+$(BOOT_SIZE)     --typecode=1:ef00 --change-name=1:$(BOOT_LABEL) \
			--new=2:0:+$(SWAP_SIZE)     --typecode=2:8200 --change-name=2:$(SWAP_LABEL) \
			--new=3:0:0                 --typecode=3:8300 --change-name=3:$(ROOT_LABEL) \
			$(DISK); \
		partprobe $(DISK); \
		udevadm settle; \
	"

vm/format:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/format"; \
		exit 1; \
	fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		mkfs.fat  -F32 -n $(BOOT_LABEL) $(PART_PREFIX)1; \
		mkswap    -L   $(SWAP_LABEL)    $(PART_PREFIX)2; \
		mkfs.ext4 -L   $(ROOT_LABEL)    $(PART_PREFIX)3; \
	"

vm/mount:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/mount"; \
		exit 1; \
	fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		mount $(ROOT_PART)              /mnt; \
		mkdir -p                        /mnt/boot; \
		mount $(BOOT_PART)              /mnt/boot; \
		swapon $(SWAP_PART); \
	"

vm/bootstrap0:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/bootstrap0"; \
		exit 1; \
	fi
	NIXUSER=root $(MAKE) vm/partition
	NIXUSER=root $(MAKE) vm/format
	NIXUSER=root $(MAKE) vm/mount
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after bootstrap0, run this to finalize. After this, do everything else in the VM
vm/bootstrap:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/bootstrap"; \
		exit 1; \
	fi
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/secrets
	NIXUSER=root $(MAKE) vm/switch
	@echo "Bootstrap complete! VM will reboot..."
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "sudo reboot"

# copy the Nix configurations into the VM.
vm/copy:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/copy"; \
		exit 1; \
	fi
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# copy our secrets into the VM
vm/secrets:
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='environment' \
		$(HOME)/.ssh/homelab_host* $(NIXUSER)@$(NIXADDR):/etc/ssh/
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='environment' \
		$(HOME)/.ssh/homelab_host* $(NIXUSER)@$(NIXADDR):/home/hass/.ssh/
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo chown -R hass:users /home/hass/.ssh && \
		sudo chmod 700 /home/hass/.ssh && \
		sudo chmod 600 /home/hass/.ssh/homelab_host* \
	"

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/switch"; \
		exit 1; \
	fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		if [ ! -d /nix-config ]; then echo '/nix-config not found on remote; run vm/copy first'; exit 1; fi; \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild \
			--flake \"/nix-config#$(NIXNAME)\" \
			switch; \
	"
