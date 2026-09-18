#!/usr/bin/env bash
# theme-picker.sh — switch the desktop colorscheme via theme-sync.sh.
#
# Picks an installed theme/variant pair and applies the matching wallpaper
# if one exists; theme-sync.sh derives every consumer's colors from the
# wallpaper path, so choosing the wallpaper is the theme switch.

set -u

THEMES_DIR="$HOME/Pictures/Wallpapers"
SYNC="$HOME/.config/scripts/theme-sync.sh"
ROFI_THEME="$HOME/.config/rofi/config.rasi"

list_entries() {
        find -L "$THEMES_DIR" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | sort | while read -r dir; do
        variant=$(basename "$dir")
        theme=$(basename "$(dirname "$dir")")
        label="$theme · $variant"
        icon="preferences-desktop-theme"
        printf '%s\0icon\x1f%s\0info\x1f%s\n' "$label" "$icon" "$dir"
    done
}

mapfile -t entries < <(list_entries)
if [[ ${#entries[@]} -eq 0 ]]; then
    rofi -e "No themes found under $THEMES_DIR"
    exit 1
fi

selection=$(list_entries | rofi -dmenu -i -no-custom \
    -theme "$ROFI_THEME" \
    -p "Theme" \
    -mesg "Enter to apply · Esc cancel" 2>/dev/null)

[[ -z "$selection" ]] && exit 0

# Re-resolve the directory from the label.
theme="${selection%% · *}"
variant="${selection##* · }"
dir="$THEMES_DIR/$theme/$variant"
[[ -d "$dir" ]] || exit 1

wallpaper=$(find -L "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort | head -1)

if [[ -z "$wallpaper" ]]; then
    notify-send -a "Theme" -i dialog-error "No wallpaper" "No image found in $dir" 2>/dev/null || true
    exit 1
fi

awww img "$wallpaper" -t fade --transition-duration 2 --transition-fps 30 >/dev/null 2>&1 &
"$SYNC" "$wallpaper" >/dev/null 2>&1 &
notify-send -a "Theme" -i preferences-desktop-theme "Theme applied" "$theme · $variant" 2>/dev/null || true
