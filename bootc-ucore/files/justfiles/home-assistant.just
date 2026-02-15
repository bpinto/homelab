hass-root-setup:
    sudo mkdir -p /srv/hass/hass
    sudo chown -R hass:hass /srv/hass

    sudo loginctl enable-linger hass

hass-user-setup:
    {{ if `whoami` == "hass" { ":" } else { error("This justfile must be run as the 'hass' user. Please switch to the 'hass' user and try again.") } }}
    systemctl --user enable --now podman-auto-update.timer
    systemctl --user enable --now container-homeassistant.service
