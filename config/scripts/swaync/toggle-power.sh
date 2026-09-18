#!/usr/bin/env bash
# Cycle power profiles via tuned (installed as tuned-ppd). Prints the new profile.
# Used by swaync toggle button: on = performance, off = balanced.
set -u
current=$(tuned-adm active 2>/dev/null | sed 's/^Current active profile: //')

case "${1:-}" in
    on|off|toggle|"")
        if [[ "$current" == "throughput-performance" ]]; then
            tuned-adm profile balanced >/dev/null 2>&1
        else
            tuned-adm profile throughput-performance >/dev/null 2>&1
        fi
        ;;
    profile)
        tuned-adm profile "$2" >/dev/null 2>&1
        ;;
esac

tuned-adm active 2>/dev/null | sed 's/^Current active profile: //'
