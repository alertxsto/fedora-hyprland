#!/usr/bin/env bash
# Screenshot (region → clipboard) for swaync. No stdout (action button).
set -u
grim -g "$(slurp)" - | wl-copy 2>/dev/null
notify-send -a Screenshot -u low "Screenshot" "Region copied to clipboard" 2>/dev/null &
