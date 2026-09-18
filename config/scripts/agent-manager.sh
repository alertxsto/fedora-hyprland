#!/usr/bin/env bash
# agent-manager.sh — install/update/status for AI coding agents, plus the
# "debug this error with an agent" entry point used by error notifications.
#
# Usage:
#   agent-manager.sh status                 show detected agents + versions
#   agent-manager.sh update-all             update every detected agent
#   agent-manager.sh install <agent>        install one agent
#   agent-manager.sh new <agent> [dir]      open a session (dir picker if omitted)
#   agent-manager.sh failed                 list failed systemd units
#   agent-manager.sh debug-last [unit]      open agent in kitty with unit logs
#   agent-manager.sh edit-config <agent>    open that agent's config

set -u

SCRIPTS_DIR="$HOME/.config/scripts"
CONFIG_DIR="$HOME/.config/opencode"
PROMPTS_DIR="$CONFIG_DIR/prompts"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-manager"
mkdir -p "$STATE_DIR"

AGENTS=(opencode pi claude codex gemini)

agent_bin() {
    case "$1" in
        opencode) echo "opencode" ;;
        pi)       echo "pi" ;;
        claude)   echo "claude" ;;
        codex)    echo "codex" ;;
        gemini)   echo "gemini" ;;
    esac
}

agent_installed() {
    command -v "$(agent_bin "$1")" >/dev/null 2>&1
}

agent_version() {
    local bin
    bin=$(agent_bin "$1")
    command -v "$bin" >/dev/null 2>&1 || return 1
    timeout 5 "$bin" --version 2>/dev/null | head -1
}

notify() {
    notify-send -a "Agent Manager" -i "$1" "$2" "$3" 2>/dev/null || true
}

detect() {
    {
        printf '\0prompt\x1fAgent status\n'
        printf '\0message\x1fDetected agents on this machine · Enter to open docs\n'
        for a in "${AGENTS[@]}"; do
            local icon label
            if agent_installed "$a"; then
                icon="emblem-ok"
                label=$(printf '%-10s %s' "$a" "$(agent_version "$a")")
            else
                icon="dialog-error"
                label=$(printf '%-10s not installed' "$a")
            fi
            printf '%s\0icon\x1f%s\n' "$label" "$icon"
        done
    } | rofi -dmenu -i -no-custom \
        -theme "$HOME/.config/rofi/config.rasi" \
        -p "Agents" \
        -mesg "Enter open docs · Esc close" 2>/dev/null | {
        read -r choice
        [[ -z "$choice" ]] && exit 0
        case "$choice" in
            *opencode*) xdg-open "https://opencode.ai/docs/" ;;
            *pi*)       xdg-open "https://pi.dev/docs" ;;
            *claude*)   xdg-open "https://docs.anthropic.com/en/docs/claude-code" ;;
            *codex*)    xdg-open "https://github.com/openai/codex" ;;
            *gemini*)   xdg-open "https://github.com/google-gemini/gemini-cli" ;;
        esac
    }
}

install_agent() {
    local agent="$1"
    case "$agent" in
        opencode)
            curl -fsSL https://opencode.ai/install | bash
            ;;
        pi)
            curl -fsSL https://pi.dev/install.sh | sh
            ;;
        claude)
            command -v npm >/dev/null || { notify dialog-error "npm missing" "Install Node.js first"; return 1; }
            npm install -g --ignore-scripts @anthropic-ai/claude-code
            ;;
        codex)
            command -v npm >/dev/null || { notify dialog-error "npm missing" "Install Node.js first"; return 1; }
            npm install -g --ignore-scripts @openai/codex
            ;;
        gemini)
            command -v npm >/dev/null || { notify dialog-error "npm missing" "Install Node.js first"; return 1; }
            npm install -g --ignore-scripts @google/gemini-cli
            ;;
        *)
            notify dialog-error "Unknown agent" "$agent"
            return 1
            ;;
    esac
}

update_agent() {
    local agent="$1"
    case "$agent" in
        opencode)
            opencode upgrade
            ;;
        pi)
            # pi ships its own installer; re-running it updates in place.
            curl -fsSL https://pi.dev/install.sh | sh
            ;;
        claude)
            npm update -g @anthropic-ai/claude-code 2>/dev/null || npm install -g --ignore-scripts @anthropic-ai/claude-code
            ;;
        codex)
            npm update -g @openai/codex 2>/dev/null || npm install -g --ignore-scripts @openai/codex
            ;;
        gemini)
            npm update -g @google/gemini-cli 2>/dev/null || npm install -g --ignore-scripts @google/gemini-cli
            ;;
        *)
            notify dialog-error "Unknown agent" "$agent"
            return 1
            ;;
    esac
}

update_all() {
    local found=0
    for a in "${AGENTS[@]}"; do
        if agent_installed "$a"; then
            found=1
            echo "== updating $a"
            update_agent "$a" && echo "   ok" || echo "   failed"
        fi
    done
    [[ $found -eq 0 ]] && echo "No agents detected."
    echo
    echo "Done. Press Enter to close."
    read -r _
}

pick_directory() {
    local start="${1:-$HOME}"
    rofi -dmenu -i -no-custom \
        -theme "$HOME/.config/rofi/config.rasi" \
        -p "Session folder" \
        -mesg "Type a path, or pick from the list" \
        -filter "$start" \
        < <(find "$start" -maxdepth 1 -mindepth 1 -type d ! -name '.*' 2>/dev/null | sort) 2>/dev/null
}

new_session() {
    local agent="$1" dir="${2:-}"
    if ! agent_installed "$agent"; then
        notify dialog-error "$agent not installed" "Install it from AI Agents → Install $agent"
        exit 1
    fi

    if [[ -z "$dir" ]]; then
        dir=$(pick_directory "$HOME")
        [[ -z "$dir" ]] && exit 0
    fi
    [[ -d "$dir" ]] || dir="$HOME"

    local bin
    bin=$(agent_bin "$agent")
    setsid nohup kitty --directory "$dir" -e "$bin" >/dev/null 2>&1 < /dev/null &
}

failed_units() {
    local units
    units=$(systemctl --user show --state=failed --property=Id --value '*' 2>/dev/null)
    units+=$'\n'$(systemctl show --state=failed --property=Id --value '*' 2>/dev/null)
    units=$(printf '%s\n' "$units" | sed '/^$/d' | sort -u)
    [[ -z "$units" ]] && return 1
    printf '%s\n' "$units"
}

debug_last() {
    local unit="${1:-}"
    if [[ -z "$unit" ]]; then
        unit=$(failed_units | head -1)
    fi
    if [[ -z "$unit" ]]; then
        notify dialog-information "No failed units" "Nothing to debug"
        exit 0
    fi
    open_debug_session "$unit"
}

open_debug_session() {
    local unit="$1"
    local log
    if [[ "$unit" == *.service && "$unit" != dbus-* ]]; then
        log=$(journalctl --user -u "$unit" -n 80 --no-pager 2>/dev/null || true)
        [[ -z "$log" ]] && log=$(journalctl -u "$unit" -n 80 --no-pager 2>/dev/null || true)
    else
        log=$(systemctl --user status "$unit" --no-pager -n 60 2>/dev/null || systemctl status "$unit" --no-pager -n 60 2>/dev/null || true)
    fi
    [[ -z "$log" ]] && log="(no logs available)"

    local prompt_file="$STATE_DIR/debug-$unit.txt"
    {
        printf 'A systemd unit on this machine failed. Help me fix it.\n\n'
        printf 'Unit: %s\n\n' "$unit"
        printf 'Recent logs:\n```\n%s\n```\n\n' "$log"
        printf 'Start by diagnosing the root cause, then propose the smallest fix. '
        printf 'Ask before changing anything outside my home directory.\n'
    } > "$prompt_file"

    setsid nohup kitty --directory "$HOME" -e opencode --prompt "$(cat "$prompt_file")" >/dev/null 2>&1 < /dev/null &
}

edit_config() {
    local agent="$1" target
    case "$agent" in
        opencode) target="$CONFIG_DIR/opencode.json" ;;
        pi)       target="$HOME/.config/pi/config.json" ;;
        *)        target="$HOME/.config/$agent" ;;
    esac
    if [[ -f "$target" ]]; then
        setsid nohup kitty -e "${EDITOR:-nvim}" "$target" >/dev/null 2>&1 < /dev/null &
    else
        notify dialog-information "No config found" "$target"
    fi
}

case "${1:-status}" in
    status)     detect ;;
    install)    install_agent "${2:?agent required}" ;;
    update-all) update_all ;;
    update)     update_agent "${2:?agent required}" ;;
    new)        new_session "${2:?agent required}" "${3:-}" ;;
    failed)     failed_units || notify dialog-information "No failed units" "All clean" ;;
    debug-last) debug_last "${2:-}" ;;
    edit-config) edit_config "${2:?agent required}" ;;
    *)
        echo "usage: $0 {status|install <agent>|update-all|update <agent>|new <agent> [dir]|failed|debug-last [unit]|edit-config <agent>}" >&2
        exit 2
        ;;
esac
