#!/usr/bin/env bash
# rfkill-unblock.sh — Clear rfkill soft-block on wireless devices (wlan + bluetooth)
# at login. Without this, some WiFi/Bluetooth adapters (e.g. MediaTek MT7921)
# stay soft-blocked and bluetooth-proxied TUIs like bluetui exit instantly.
# Usage: rfkill-unblock.sh

for dev in wlan bluetooth; do
    if rfkill list "$dev" 2>/dev/null | grep -q "Soft blocked: yes"; then
        if rfkill unblock "$dev" 2>/dev/null; then
            echo "Unblocked $dev"
        elif sudo -n rfkill unblock "$dev" 2>/dev/null; then
            echo "Unblocked $dev (via sudo)"
        else
            echo "Warning: $dev is rfkill soft-blocked and could not be unblocked" >&2
        fi
    fi
done
