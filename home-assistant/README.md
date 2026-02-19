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

Run setup script with the **core** user:

```bash
ssh -i ~/.ssh/homelab core@IP.OF.YOUR.BOX
blujust hass-root-setup
```

### Configuring hass user

Run setup script with the **hass** user:

```bash
ssh -i ~/.ssh/homelab hass@IP.OF.YOUR.BOX
blujust hass-user-git-clone YOUR_GITHUB_TOKEN
blujust hass-user-setup
```
