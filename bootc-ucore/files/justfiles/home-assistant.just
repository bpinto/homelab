hass-root-setup:
    sudo mkdir -p /srv/hass/havc-data
    sudo chown -R hass:hass /srv/hass

    sudo loginctl enable-linger hass

hass-user-git-clone GITHUB_TOKEN REPO_URL="https://github.com/bpinto/homelab.git" BRANCH="develop": _check-hass-user
    #!/usr/bin/env bash
    set -euxo pipefail

    # Check if directory exists and is not empty
    if [ -d /srv/hass/hass ]; then
        echo "Error: /srv/hass/hass directory already exists!"
        echo "Please backup and remove the existing configuration first:"
        echo "  mv /srv/hass/hass /srv/hass/hass.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  rm -rf /srv/hass/hass"
        exit 1
    fi

    # Clone the repository with token authentication
    REPO_URL="{{ REPO_URL }}"
    REPO_URL_NO_HTTPS="${REPO_URL#https://}"
    git clone --branch {{ BRANCH }} "https://{{ GITHUB_TOKEN }}@${REPO_URL_NO_HTTPS}" \
        /srv/hass/hass

    # Configure git
    cd /srv/hass/hass
    git config user.name "Home Assistant"
    git config user.email "homeassistant@localhost"

    echo "Home Assistant configuration cloned from {{ REPO_URL }} ({{ BRANCH }} branch)"

hass-user-setup: _check-hass-user
    systemctl --user enable --now podman-auto-update.timer
    systemctl --user enable --now container-homeassistant.service
    systemctl --user enable --now container-homeassistant-version-control.service

[private]
_check-hass-user:
    {{ if `whoami` != "hass" { error("This justfile must be run as the 'hass' user. Please switch to the 'hass' user and try again.") } else { "" } }}
