#!/usr/bin/env bash
# rofi Home — single search box for actions + apps (combi mode).
#
# The script is used as a rofi script mode inside a combi:
#   rofi -show combi -modes "combi,drun,hom:home.sh" -combi-modes "hom,drun"
#
# Entries come from menu.tsv (id, parent, icon, label, action, keywords).
# Selecting a row either:
#   - runs a command (cmd:...) detached, or
#   - re-launches rofi rooted at a submenu (submenu:...) with -replace, or
#   - returns to the parent menu (back:...).
#
# The root call shows the current submenu (ROFI_HOME_MENU, default "root"),
# so "back" is just re-launching with a different root.

set -u

MENU_FILE="${ROFI_HOME_MENU_FILE:-$HOME/.config/rofi/menu.tsv}"
ROFI_THEME="${ROFI_HOME_THEME:-$HOME/.config/rofi/config.rasi}"
ROFI_PID="${ROFI_HOME_PID:-/tmp/rofi-home.pid}"
ROFI_MODE="hom"
SELF="$HOME/.config/rofi/scripts/home.sh"

emit_submenu() {
    local id="$1"
    printf '\0message\x1fEnter to open · Tab for apps · Esc to close\n'
    while IFS=$'\t' read -r row_id row_parent row_icon row_label row_action row_keywords; do
        [[ -z "$row_id" || "$row_id" == \#* ]] && continue
        [[ "$row_parent" == "$id" ]] || continue
        printf '%s\0icon\x1f%s\0info\x1f%s\0meta\x1f%s\n' "$row_label" "$row_icon" "$row_action" "$row_keywords"
    done < "$MENU_FILE"

    # Back row for anything that is not root.
    if [[ "$id" != "root" ]]; then
        local parent
        parent=$(awk -F'\t' -v id="$id" '$1==id {print $2; exit}' "$MENU_FILE")
        [[ -z "$parent" ]] && parent="root"
        printf '‹ Back\0icon\x1fgo-previous\0info\x1fback:%s\n' "$parent"
    fi
}

open_menu() {
    local id="$1"
    ROFI_HOME_MENU="$id" setsid nohup rofi \
        -show combi \
        -modes "combi,drun,$ROFI_MODE:$SELF" \
        -combi-modes "$ROFI_MODE,drun" \
        -combi-hide-mode-prefix \
        -display-combi "Home" \
        -theme "$ROFI_THEME" \
        -pid "$ROFI_PID" \
        -replace \
        >/dev/null 2>&1 < /dev/null &
    disown 2>/dev/null || true
}

case "${ROFI_RETV:-0}" in
    0)
        emit_submenu "${ROFI_HOME_MENU:-root}"
        ;;
    1)
        action="${ROFI_INFO:-}"
        case "$action" in
            submenu:*)
                open_menu "${action#submenu:}"
                ;;
            back:*)
                open_menu "${action#back:}"
                ;;
            cmd:*)
                cmd="${action#cmd:}"
                setsid nohup bash -lc "$cmd" >/dev/null 2>&1 < /dev/null &
                disown 2>/dev/null || true
                ;;
        esac
        ;;
esac
