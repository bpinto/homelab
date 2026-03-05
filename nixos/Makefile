# Homelab NixOS Configuration Makefile

# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXNAME ?= bare # Options: vm-aarch64, bare
# Default user: homelab for bare, homelab-vm for vm* (override by exporting NIXUSER)
NIXUSER ?= $(shell if echo "$(NIXNAME)" | grep -q '^vm'; then echo homelab-vm; else echo homelab; fi)

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options for VM access (bootstrap-focused)
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

.PHONY: help
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
	@echo "  make vm/secrets      - Copy SSH/GPG keys to VM"
	@echo ""
	@echo "Local Operations (run inside VM or on bare metal):"
	@echo "  make switch          - Apply configuration changes"
	@echo "  make test            - Test configuration without activating"
	@echo ""
	@echo "Required variables for VM operations:"
	@echo "  NIXADDR=<VM IP>      - VM IP address (e.g., 192.168.58.130)"
	@echo "  NIXNAME=<config>     - Configuration name (default: bare)"
	@echo "  NIXUSER=<user>       - Username (default: 'homelab' for bare, 'homelab-vm' for vm)"

.PHONY: switch
switch: ## Apply configuration (run inside VM or bare metal)
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"

.PHONY: test
test: ## Test configuration without activating
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIXNAME)"

# Backup secrets so that we can transfer them to new machines via
# sneakernet or other means.
.PHONY: secrets/backup
secrets/backup:
	tar -czvf $(MAKEFILE_DIR)/backup.tar.gz \
		-C $(HOME) \
		--exclude='.gnupg/.#*' \
		--exclude='.gnupg/S.*' \
		--exclude='.gnupg/*.conf' \
		--exclude='.ssh/environment' \
		.ssh/ \
		.gnupg

.PHONY: secrets/restore
secrets/restore:
	if [ ! -f $(MAKEFILE_DIR)/backup.tar.gz ]; then \
		echo "Error: backup.tar.gz not found in $(MAKEFILE_DIR)"; \
		exit 1; \
	fi
	echo "Restoring SSH keys and GPG keyring from backup..."
	mkdir -p $(HOME)/.ssh $(HOME)/.gnupg
	tar -xzvf $(MAKEFILE_DIR)/backup.tar.gz -C $(HOME)
	chmod 700 $(HOME)/.ssh $(HOME)/.gnupg
	chmod 600 $(HOME)/.ssh/* || true
	chmod 700 $(HOME)/.gnupg/* || true

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and the root password set to "root". This will install NixOS.
vm/bootstrap0:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/bootstrap0"; \
		exit 1; \
	fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- set 1 esp on; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		sleep 1; \
		mkfs.fat -F 32 -n boot /dev/sda1; \
		mkfs.ext4 -L nixos /dev/sda2; \
		mkswap -L swap /dev/sda3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/bootstrap"; \
		exit 1; \
	fi
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/secrets
	@echo "Bootstrap complete! VM will reboot..."
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "sudo reboot"

# copy our secrets into the VM
vm/secrets:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/secrets"; \
		exit 1; \
	fi
	@echo "Copying secrets to VM..."
	@# GPG keyring
	@if [ -d "$(HOME)/.gnupg" ]; then \
		rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
			--exclude='.#*' \
			--exclude='S.*' \
			--exclude='*.conf' \
			$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg; \
	fi
	@# SSH keys
	@if [ -d "$(HOME)/.ssh" ]; then \
		rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
			--exclude='environment' \
			$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh; \
	fi

# copy the Nix configurations into the VM.
vm/copy:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/copy"; \
		exit 1; \
	fi
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='.jj/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	@if [ "$(NIXADDR)" = "unset" ]; then \
		echo "Error: NIXADDR is not set. Usage: NIXADDR=<ip> make vm/switch"; \
		exit 1; \
	fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		if [ ! -d /nix-config ]; then echo '/nix-config not found on remote; run vm/copy first'; exit 1; fi; \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\"; \
	"

# Build a WSL installer
.PHONY: wsl
wsl:
	 nix build ".#nixosConfigurations.wsl.config.system.build.installer"
