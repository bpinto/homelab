hass-root-setup:
    sudo mkdir -p /srv/hass/hass
    sudo mkdir -p /srv/hass/havc-data
    sudo chown -R hass:hass /srv/hass

    sudo loginctl enable-linger hass

hass-user-setup: _check-hass-user
    systemctl --user enable --now podman-auto-update.timer
    systemctl --user enable --now container-homeassistant.service

[private]
_check-hass-user:
    {{ if `whoami` != "hass" { error("This justfile must be run as the 'hass' user. Please switch to the 'hass' user and try again.") } else { "" } }}
