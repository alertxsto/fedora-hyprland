#!/usr/bin/env bash
# volume.sh — Volume control with wob OSD (center-bottom bar)
# Usage: volume.sh [up|down|mute]

FIFO="$XDG_RUNTIME_DIR/wob.fifo"

case "$1" in
    up)   wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

# Get current volume & mute state
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED" || true)

# Write to wob FIFO (shows OSD bar)
if [ -p "$FIFO" ]; then
    if [ "$MUTED" -gt 0 ]; then
        echo "0" > "$FIFO"
    else
        echo "$VOL" > "$FIFO"
    fi
fi
