#!/usr/bin/env bash
# wob-daemon.sh — Starts wob OSD daemon with current theme colors
# wob reads values 0-100 from the FIFO and renders a centered progress bar.
# Called on autostart and on theme change.

FIFO="$XDG_RUNTIME_DIR/wob.fifo"

# Kill any existing wob instance
pkill wob 2>/dev/null
rm -f "$FIFO"

# Read current theme colors from waybar's current.css
# Parse @define-color variables to get BASE and ACCENT hex values
COLORS_CSS="$HOME/.config/waybar/colors/current.css"

BASE="#24273a"
ACCENT="#c6a0f6"
TEXT="#cad3f5"

if [ -f "$COLORS_CSS" ]; then
    _base=$(grep "@define-color base " "$COLORS_CSS" | grep -oP '#[0-9a-fA-F]{6}' | head -1)
    _accent=$(grep "@define-color mauve" "$COLORS_CSS" | grep -oP '#[0-9a-fA-F]{6}' | head -1)
    _text=$(grep "@define-color text " "$COLORS_CSS" | grep -oP '#[0-9a-fA-F]{6}' | head -1)
    [ -n "$_base"   ] && BASE="$_base"
    [ -n "$_accent" ] && ACCENT="$_accent"
    [ -n "$_text"   ] && TEXT="$_text"
fi

# Convert #RRGGBB to AARRGGBB (wob format, 8 hex chars, alpha first)
to_wob_color() {
    local hex="${1#\#}"  # strip leading #
    local alpha="$2"     # 2-char hex alpha, e.g. "e6" = ~90%
    echo "${alpha}${hex}"
}

BG_COLOR=$(to_wob_color "$BASE"   "e6")   # 90% opacity background
BAR_COLOR=$(to_wob_color "$ACCENT" "ff")   # 100% accent bar
BORDER_COLOR=$(to_wob_color "$ACCENT" "cc") # 80% accent border

# Create FIFO and start wob
mkfifo "$FIFO"

wob \
    --anchor bottom \
    --margin 120 \
    --width 380 \
    --height 36 \
    --border 2 \
    --padding 4 \
    --border-radius 18 \
    --background-color "$BG_COLOR" \
    --bar-color        "$BAR_COLOR" \
    --border-color     "$BORDER_COLOR" \
    < "$FIFO" &

echo "wob started with FIFO: $FIFO"
