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

> [!NOTE]
> For advanced customization, modify the [butane template](https://github.com/bpinto/homelab/raw/main/bootc-ucore/template.butane) and compile it with [butane](https://coreos.github.io/butane/getting-started/).

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

### Configuring

SSH into the CoreOS system with the **core** user:

```bash
ssh -i ~/.ssh/homelab core@IP.OF.YOUR.BOX
```

Run automatic setup script:

```bash
blujust hass-root-setup
```

### Running

SSH into the CoreOS system with the **hass** user:

```bash
ssh -i ~/.ssh/homelab hass@IP.OF.YOUR.BOX
```

Run Home Assistant container:

```bash
blujust hass-user-setup
```
