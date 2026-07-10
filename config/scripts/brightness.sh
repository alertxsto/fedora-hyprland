#!/usr/bin/env bash
# brightness.sh — Brightness control with wob OSD (center-bottom bar)
# Usage: brightness.sh [up|down]

FIFO="$XDG_RUNTIME_DIR/wob.fifo"

case "$1" in
    up)   brightnessctl -e4 -n2 set 5%+ ;;
    down) brightnessctl -e4 -n2 set 5%- ;;
esac

# Get current brightness percentage
BRIGHT=$(brightnessctl get)
MAX=$(brightnessctl max)
PCT=$(( BRIGHT * 100 / MAX ))

# Write to wob FIFO (shows OSD bar)
if [ -p "$FIFO" ]; then
    echo "$PCT" > "$FIFO"
fi
