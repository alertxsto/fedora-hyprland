#!/usr/bin/env bash
# rofi-keybinds.sh — Hyprland keybinding cheatsheet.
#
# Binds carry their own descriptions (the `description` flag in hyprland.lua),
# so hyprctl binds -j is enough. Selecting a row copies the combo.

set -u

BINDINGS=$(hyprctl binds -j 2>/dev/null)
[[ -z "$BINDINGS" ]] && exit 1

python3 - "$BINDINGS" <<'PY' > /tmp/rofi-keybinds.rows
import json, sys

binds = json.loads(sys.argv[1])
MODS = {64: "SUPER", 8: "ALT", 4: "CTRL", 1: "SHIFT"}

def modname(mask):
    return "+".join(n for b, n in sorted(MODS.items(), reverse=True) if mask & b)

rows = []
for b in binds:
    if b.get("mouse") or not b.get("key"):
        continue
    combo = f"{modname(b.get('modmask', 0))}+{b['key']}".lstrip("+")
    desc = b.get("description") or b.get("dispatcher", "")
    if desc == "__lua":
        desc = "custom"
    rows.append((combo, desc))

rows.sort()
for combo, desc in rows:
    print(f"{combo}\t{desc}")
PY

if [[ ! -s /tmp/rofi-keybinds.rows ]]; then
    rofi -e "No keybindings found."
    exit 1
fi

printf '\0prompt\x1fKeybindings\n\0message\x1fEnter to copy · Esc close\n' > /tmp/rofi-keybinds.in
awk -F'\t' '{ printf "%-28s %s\0icon\x1finput-keyboard\n", $1, $2 }' /tmp/rofi-keybinds.rows >> /tmp/rofi-keybinds.in

selected=$(rofi -dmenu -i -no-custom \
    -theme "$HOME/.config/rofi/config.rasi" \
    -p "Keybindings" \
    -mesg "Enter to copy · Esc close" \
    < /tmp/rofi-keybinds.in 2>/dev/null)

rm -f /tmp/rofi-keybinds.rows /tmp/rofi-keybinds.in

if [[ -n "$selected" ]]; then
    combo=$(printf '%s' "$selected" | awk '{print $1}')
    printf '%s' "$combo" | wl-copy 2>/dev/null
    notify-send -a "Keybindings" -i input-keyboard "Copied" "$combo" 2>/dev/null || true
fi
