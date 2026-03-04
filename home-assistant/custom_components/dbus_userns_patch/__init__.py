"""Patch to allow DBus connections from inside a user namespace."""

from __future__ import annotations

import dbus_fast.auth

from homeassistant.core import HomeAssistant
from homeassistant.helpers.typing import ConfigType

async def async_setup(hass: HomeAssistant, config: ConfigType) -> bool:
    dbus_fast.auth.UID_NOT_SPECIFIED = None
    for entry in hass.config_entries.async_entries('bluetooth', False, False):
        hass.config_entries.async_schedule_reload(entry.entry_id)
    return True
