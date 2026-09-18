#!/usr/bin/env bash
# Bluetooth power toggle for swaync. Prints "true"/"false".
set -u
case "${1:-}" in
    on|off)
        bluetoothctl power "$1" >/dev/null
        ;;
    "")
        if [[ "${SWAYNC_TOGGLE_STATE:-}" == true ]]; then
            bluetoothctl power off >/dev/null
        else
            bluetoothctl power on >/dev/null
        fi
        ;;
esac

bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && echo true || echo false
