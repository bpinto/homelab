hass-root-setup:
    sudo mkdir -p /srv/hass/
    sudo chown -R hass:hass /srv/hass

    # Prevent containers from being killed when the user logs out
    sudo loginctl enable-linger hass

hass-user-git-clone GITHUB_TOKEN REPO_URL="https://github.com/bpinto/homelab.git" BRANCH="main": _check-hass-user
    #!/usr/bin/env bash
    set -euxo pipefail

    # Check if directory exists and is not empty
    if [ -d /srv/hass/homelab ]; then
        echo "Error: /srv/hass/homelab directory already exists!"
        exit 1
    fi

    # Clone the repository with token authentication
    REPO_URL="{{ REPO_URL }}"
    REPO_URL_NO_HTTPS="${REPO_URL#https://}"
    git clone --branch {{ BRANCH }} "https://{{ GITHUB_TOKEN }}@${REPO_URL_NO_HTTPS}" \
        /srv/hass/homelab

    # Configure git
    cd /srv/hass/homelab
    git config user.name "Home Assistant"
    git config user.email "homeassistant@localhost"

    echo "Home Assistant configuration cloned from {{ REPO_URL }} ({{ BRANCH }} branch)"

hass-user-setup: _check-hass-user
    systemctl --user enable --now podman-auto-update.timer
    systemctl --user enable --now container-homeassistant.service
    systemctl --user enable --now container-homeassistant-addon-esphome.service
    systemctl --user enable --now container-homeassistant-addon-matter-server.service
    systemctl --user enable --now container-homeassistant-addon-predbat.service

[private]
_check-hass-user:
    {{ if `whoami` != "hass" { error("This justfile must be run as the 'hass' user. Please switch to the 'hass' user and try again.") } else { "" } }}
