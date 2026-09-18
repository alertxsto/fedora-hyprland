#!/usr/bin/env bash
# Session actions for swaync menubar (lock / logout / reboot / shutdown).
# stdout only on failure so swaync shows nothing on success.
set -u
case "${1:-}" in
    lock)
        hyprshutdown lock 2>/dev/null || loginctl lock-session
        ;;
    logout)
        uwsm stop 2>/dev/null || hyprctl dispatch exit
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        hyprshutdown 2>/dev/null || systemctl poweroff
        ;;
    settings)
        # No dedicated settings GUI installed; fall back to pavucontrol for now.
        setsid pavucontrol >/dev/null 2>&1 &
        ;;
    files)
        setsid thunar >/dev/null 2>&1 &
        ;;
esac
