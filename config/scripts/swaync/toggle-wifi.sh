#!/usr/bin/env bash
# WiFi toggle for swaync buttons-grid / menubar.
# Prints "true"/"false" so swaync keeps the checked state in sync.
set -u
case "${1:-}" in
    on|off)
        nmcli radio wifi "$1"
        ;;
    "")
        if [[ "${SWAYNC_TOGGLE_STATE:-}" == true ]]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
esac

if [[ $(nmcli radio wifi) == "enabled" ]]; then
    echo true
else
    echo false
fi
