## Installation

There are [varying methods](https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/) of CoreOS installation for bare metal, cloud providers, and virtualization platforms.

### Image verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by running the following command:

```bash
cosign verify --key https://github.com/bpinto/homelab/raw/main/bootc-ucore/cosign.pub ghcr.io/bpinto/homelab-ucore:latest
```

### Ignition file

1. Download the [ignition template](https://github.com/bpinto/homelab/raw/main/bootc-ucore/template.ign) and update the SSH keys.
2. Host the file on a web server or USB drive accessible during installation.
3. Use the ignition file during CoreOS installation to automatically rebase to `ghcr.io/bpinto/homelab-ucore:latest` on first boot.

> [!TIP]
> Run `python3 -m http.server` in the ignition file directory for a quick web server, then use `http://<IP_ADDRESS>:8000/template.ign` during installation.

### Installing

Confirm the path of the system’s hard drive (probably /dev/sda).

```bash
sudo fdisk -l
```

Run the following command in the terminal to launch the installer.

```bash
sudo coreos-installer install /dev/sdX --insecure-ignition --ignition-url http://<IP_ADDRESS>:8000/template.ign
```

And then reboot to complete the installation.

```bash
sudo reboot
```

## Home Assistant configuration

### Creating a fine-grained Personal Access Token

1. Navigate to [https://github.com/settings/personal-access-tokens/new](https://github.com/settings/personal-access-tokens/new)
2. Configure the token with the following settings:
   - **Token name**: Give it a descriptive name (e.g., "Home Assistant Homelab Access")
   - **Expiration**: Select "No expiration"
   - **Repository access**: Select "Only select repositories" and choose the `homelab` repository
   - **Permissions**: Under "Repository permissions", set:
     - **Contents**: Access: Read and write
     - **Metadata**: Access: Read-only (automatically selected)
3. Click "Generate token" at the bottom of the page

> [!WARNING]
> Treat this token like a password. Anyone with access to it can read and write to your homelab repository's develop branch.

### Configuring core user

SSH into the CoreOS system with the **core** user:

```bash
ssh -i ~/.ssh/homelab core@IP.OF.YOUR.BOX
```

Run automatic setup script:

```bash
blujust hass-root-setup
```

### Configuring hass user

SSH into the CoreOS system with the **hass** user:

```bash
ssh -i ~/.ssh/homelab hass@IP.OF.YOUR.BOX
```

Run automatic setup script:

```bash
blujust hass-user-git-clone YOUR_GITHUB_TOKEN
blujust hass-user-setup
```
