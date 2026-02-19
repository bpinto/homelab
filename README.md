# Project Overview

This repository contains multiple subprojects, each with its own documentation and purpose. Please refer to the individual README files for detailed information about each subproject.

## Subprojects

- [bootc-ucore](bootc-ucore/README.md): uCore (Fedora CoreOS) boot configuration and utilities.
- [home-assistant](home-assistant/README.md): Home automation tools and integrations.

Explore each subproject for setup instructions, usage, and contribution guidelines.

## Tailscale

An [auth key](https://login.tailscale.com/admin/settings/keys) is required to set up Tailscale. It's recommended to create a non-reusable key and to [disable key expiry](https://tailscale.com/docs/features/access-control/key-expiry#disabling-key-expiry) after creating the key.

SSH into the CoreOS system with the **core** user:

```bash
ssh -i ~/.ssh/homelab core@IP.OF.YOUR.BOX
blujust tailscale-root-setup TAILSCALE_AUTH_KEY
```
