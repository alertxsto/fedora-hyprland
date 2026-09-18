#!/usr/bin/env bash
# agent-watch.sh — replace fumon: notify on failed systemd units, with
# actions that hand the failure straight to an AI agent.
#
# Reuses fumon's event stream (busctl PropertiesChanged on ActiveState) so
# we get the same coverage, but sends notifications via notify-send -A so
# the user can click "Debug with AI" or "Copy logs".

set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-watch"
mkdir -p "$STATE_DIR"
FAILED_FILE="$STATE_DIR/failed-units"
NOTIF_FILE="$STATE_DIR/notif-ids"

touch "$FAILED_FILE" "$NOTIF_FILE"

MANAGER="$HOME/.config/scripts/agent-manager.sh"

log() {
    printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$STATE_DIR/agent-watch.log"
}

unit_id_from_path() {
    # Input is the escaped path tail, e.g. "unit/watch_2dtest_2eservice".
    local unit="${1#unit/}"
    unit="${unit%%\"*}"
    # systemd escapes: _40=@ _2e=. _5f=_ _2d=- _5c=\
    printf '%s' "$unit" | sed \
        -e 's/_40/@/g' -e 's/_2e/./g' -e 's/_5f/_/g' -e 's/_2d/-/g' -e 's/_5c/\\/g'
}

get_notif_id() {
    awk -F';' -v u="$1" '$1==u {print $2; exit}' "$NOTIF_FILE"
}

set_notif_id() {
    local unit="$1" id="$2"
    awk -F';' -v u="$unit" '$1!=u' "$NOTIF_FILE" > "$NOTIF_FILE.tmp" 2>/dev/null || true
    printf '%s;%s\n' "$unit" "$id" >> "$NOTIF_FILE.tmp"
    mv "$NOTIF_FILE.tmp" "$NOTIF_FILE"
}

drop_notif_id() {
    local unit="$1"
    awk -F';' -v u="$unit" '$1!=u' "$NOTIF_FILE" > "$NOTIF_FILE.tmp" 2>/dev/null || true
    mv "$NOTIF_FILE.tmp" "$NOTIF_FILE"
}

list_contains() {
    grep -qxF "$1" "$FAILED_FILE" 2>/dev/null
}

add_failed() {
    list_contains "$1" || printf '%s\n' "$1" >> "$FAILED_FILE"
}

del_failed() {
    grep -vxF "$1" "$FAILED_FILE" > "$FAILED_FILE.tmp" 2>/dev/null || true
    mv "$FAILED_FILE.tmp" "$FAILED_FILE"
}

notify_failed() {
    local unit="$1"
    local logs
    logs=$(journalctl --user -u "$unit" -n 25 --no-pager 2>/dev/null || true)
    [[ -z "$logs" ]] && logs=$(journalctl -u "$unit" -n 25 --no-pager 2>/dev/null || true)
    [[ -z "$logs" ]] && logs="(no journal entries)"

    # notify-send -A blocks until an action is chosen (or the notification
    # closes). Run it in the background so the watcher keeps listening.
    (
        action=$(notify-send \
            -a "Agent Watch" \
            -u critical \
            -i dialog-warning \
            -A "agent=Debug with AI" \
            -A "copy=Copy logs" \
            -h "string:unit:$unit" \
            "Failed unit: $unit" \
            "Click to debug with an AI agent, or copy the logs." 2>/dev/null)

        case "$action" in
            agent)
                printf '%s\n' "$unit" > "$STATE_DIR/last-failed-unit"
                setsid nohup "$MANAGER" debug-last "$unit" >/dev/null 2>&1 < /dev/null &
                ;;
            copy)
                printf '%s\n' "$logs" | wl-copy 2>/dev/null
                notify-send -a "Agent Watch" -i edit-copy "Copied" "Logs for $unit copied to clipboard" 2>/dev/null || true
                ;;
        esac
    ) &
}

check_initial() {
    local units
    units=$(systemctl --user show --state=failed --property=Id --value '*' 2>/dev/null)
    units+=$'\n'$(systemctl show --state=failed --property=Id --value '*' 2>/dev/null)
    while read -r unit; do
        [[ -z "$unit" ]] && continue
        add_failed "$unit"
        notify_failed "$unit"
    done < <(printf '%s\n' "$units" | sed '/^$/d' | sort -u)
}

if ! command -v notify-send >/dev/null 2>&1; then
    echo "notify-send not found" >&2
    exit 1
fi

log "agent-watch started"
check_initial

busctl --user monitor \
    --json short \
    --match "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'" |
while read -r line; do
    case "$line" in
        *'"path":"/org/freedesktop/systemd1/unit/'*) ;;
        *) continue ;;
    esac
    case "$line" in
        *'"ActiveState":{'*) ;;
        *) continue ;;
    esac

    unit=$(unit_id_from_path "${line#*\"path\":\"/org/freedesktop/systemd1/}")
    [[ -z "$unit" ]] && continue

    if list_contains "$unit"; then
        case "$line" in
            *'{"ActiveState":{"type":"s","data":"failed"}'* | *'{"ActiveState":{"data":"failed","type":"s"}'*)
                continue
                ;;
            *)
                del_failed "$unit"
                log "unit recovered: $unit"
                notify-send -a "Agent Watch" -u normal -i dialog-info \
                    "Unit recovered" "$unit" 2>/dev/null || true
                ;;
        esac
    else
        case "$line" in
            *'{"ActiveState":{"type":"s","data":"failed"}'* | *'{"ActiveState":{"data":"failed","type":"s"}'*)
                add_failed "$unit"
                log "unit failed: $unit"
                notify_failed "$unit"
                ;;
        esac
    fi
done
