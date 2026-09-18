#!/usr/bin/env bash
set -euo pipefail

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Banner ──
banner() {
    local color="$1"
    printf "${color}${BOLD}\n"
    cat << 'BANNER'
██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗
██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
BANNER
    printf "${NC}"
    printf "  ${DIM}dotfiles  ·  Hyprland  ·  Fedora / openSUSE${NC}\n\n"
}

# ── Clear + banner ──
[ -t 1 ] && printf '\033[2J\033[H'
banner "${CYAN}"

# ── Helpers ──
_step=0
step() {
    _step=$((_step + 1))
    printf "\n${BOLD}${BLUE}[%d]${NC} ${BOLD}%s${NC}\n" "$_step" "$*"
}

ok()   { printf "    ${GREEN}✔${NC}  %s\n" "$*"; }
info() { printf "    ${CYAN}→${NC}  %s\n" "$*"; }
warn() { printf "    ${YELLOW}⚠${NC}  %s\n" "$*"; }
err()  { printf "    ${RED}✘${NC}  %s\n" "$*" >&2; }
die()  { err "$*"; exit 1; }

# ── Pre-flight ──
step "Pre-flight checks"

if [ "$(id -u)" -eq 0 ]; then
    die "Don't run this as root. sudo will be called when needed."
fi

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
printf "${DIM}Repo: %s${NC}\n" "$DOTFILES"

if [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
    PKG_MGR="dnf"
    FEDORA_VER="$(rpm -E %fedora)"
elif [ -f /etc/os-release ] && grep -qi "suse\|opensuse" /etc/os-release; then
    DISTRO="opensuse"
    PKG_MGR="zypper"
else
    die "Unsupported distro. Only Fedora and openSUSE are supported."
fi
ok "Detected: ${DISTRO}${FEDORA_VER:+ ${FEDORA_VER}}"

# COPR repos required on Fedora: Hyprland stack, starship, ghostty.
# hyprland / hyprpolkitagent / xdg-desktop-portal-hyprland / awww are NOT
# in the Fedora repos; waybar-git ships the fix for Lua-based Hyprland configs.
if [ "$DISTRO" = "fedora" ]; then
    if ! dnf copr list 2>/dev/null | grep -q "lionheartp/Hyprland"; then
        info "Enabling COPR: lionheartp/Hyprland (Hyprland stack + waybar-git + awww)"
        sudo dnf -y copr enable lionheartp/Hyprland "fedora-${FEDORA_VER}-x86_64" || \
            die "Failed to enable COPR lionheartp/Hyprland"
    fi
    if ! dnf copr list 2>/dev/null | grep -q "atim/starship"; then
        info "Enabling COPR: atim/starship"
        sudo dnf -y copr enable atim/starship "fedora-${FEDORA_VER}-x86_64" || \
            warn "Failed to enable COPR atim/starship — starship will be skipped"
    fi
    if ! dnf copr list 2>/dev/null | grep -q "ponesicek/ghostty-bin"; then
        info "Enabling COPR: ponesicek/ghostty-bin"
        sudo dnf -y copr enable ponesicek/ghostty-bin "fedora-${FEDORA_VER}-x86_64" || \
            warn "Failed to enable COPR ponesicek/ghostty-bin — ghostty will be skipped"
    fi
    ok "COPR repositories ready."
fi

# ── Backup helper ──
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
_backup_created=0

backup() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        if [ "$_backup_created" -eq 0 ]; then
            mkdir -p "$BACKUP_DIR"
            _backup_created=1
        fi
        local rel="${target#"$HOME/"}"
        local dst="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$dst")"
        cp -r "$target" "$dst"
        warn "Backed up: ~/${rel}"
    fi
}

deploy_link() {
    local src="$1" dst="$2"
    backup "$dst"
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    ok "Linked: $(basename "$dst")"
}

# ═════════════════════════════════════════════════════════════════════════════
# [1] Install packages
# ═════════════════════════════════════════════════════════════════════════════
step "Installing packages"

FEDORA_PKGS=(
    hyprland waybar-git rofi kitty fish
    starship fastfetch btop
    ImageMagick pipewire wireplumber
    playerctl brightnessctl flameshot
    eza bat ripgrep fd-find zoxide git-delta
    papirus-icon-theme
    hyprpolkitagent                           # polkit agent — required for file manager partition mounting
    xdg-desktop-portal-hyprland               # screensharing + file pickers on Wayland
    xdg-desktop-portal-gtk                    # GTK fallback portal (file chooser for GTK apps)
    SwayNotificationCenter                    # notification daemon with panel, DND, silent mode
    libnotify                                 # notify-send — used by apps to send desktop notifications
    wob                                       # Wayland overlay bar — volume/brightness OSD
    awww                                      # wallpaper daemon (swww successor)
    hyprland-guiutils                         # hyprland-share-picker and friends
    hyprland-qt-support                       # Qt platform integration (qt6 apps theming)
    hyprshutdown                              # graceful shutdown dialog (SUPER+M)
    hyprlock                                  # session lock handler (Power → Lock)
    thunar exo                                # file manager + "Open Terminal Here" action
    pavucontrol                               # pulseaudio/pipewire volume GUI (waybar click)
    tuned-ppd                                 # provides the PowerProfiles D-Bus service on Fedora
    rofi-themes                               # Arc-Dark + gruvbox themes shipped by Fedora
    ghostty                                   # second terminal (theme-synced)
    neovim                                    # LazyVim editor
    # Rofi home / agent tooling dependencies
    grim slurp wl-clipboard                   # screenshots + clipboard (rofi menu, swaync, agent-watch)
    hyprpicker                                # color picker (rofi Capture menu)
    xdg-utils                                 # xdg-open (Learn links, agent-manager)
    breeze-cursor-theme                       # cursor theme set in hyprland.lua
    nodejs22-npm                              # npm — agent-manager installs claude/codex/gemini
    python3                                   # rofi-keybinds.sh + helper parsing
)

OPENSUSE_PKGS=(
    hyprland waybar rofi kitty fish
    starship fastfetch btop
    ImageMagick pipewire wireplumber
    playerctl brightnessctl flameshot
    eza bat ripgrep fd zoxide git-delta
    papirus-icon-theme
    hyprpolkitagent                           # polkit agent — required for file manager partition mounting
    xdg-desktop-portal-hyprland               # screensharing + file pickers on Wayland
    xdg-desktop-portal-gtk                    # GTK fallback portal
    SwayNotificationCenter                    # notification daemon with panel, DND, silent mode
    libnotify-tools                           # notify-send — used by apps to send desktop notifications
    wob                                       # Wayland overlay bar — volume/brightness OSD
    awww                                      # wallpaper daemon (swww successor)
    hyprland-guiutils                         # hyprland-share-picker and friends
    hyprshutdown                              # graceful shutdown dialog (SUPER+M)
    hyprlock                                  # session lock handler (Power → Lock)
    thunar exo                                # file manager + "Open Terminal Here" action
    pavucontrol                               # volume GUI (waybar click)
    power-profiles-daemon                     # PowerProfiles D-Bus service (openSUSE)
    neovim                                    # LazyVim editor
    # Rofi home / agent tooling dependencies
    grim slurp wl-clipboard                   # screenshots + clipboard (rofi menu, swaync, agent-watch)
    hyprpicker                                # color picker (rofi Capture menu)
    xdg-utils                                 # xdg-open (Learn links, agent-manager)
    nodejs22-npm                              # npm — agent-manager installs claude/codex/gemini
    python3                                   # rofi-keybinds.sh + helper parsing
)

case "$DISTRO" in
    fedora)
        sudo dnf install -y --skip-unavailable "${FEDORA_PKGS[@]}"
        ;;
    opensuse)
        sudo zypper install -y "${OPENSUSE_PKGS[@]}"
        ;;
esac

ok "Packages installed."

# ═════════════════════════════════════════════════════════════════════════════
# [2] Polkit rule — allow wheel-group users to mount drives without password
# ═════════════════════════════════════════════════════════════════════════════
step "Configuring polkit rule for drive mounting"

POLKIT_RULE_DIR="/etc/polkit-1/rules.d"
POLKIT_RULE_FILE="$POLKIT_RULE_DIR/10-udisks2-allow-mount.rules"

if [ -f "$POLKIT_RULE_FILE" ]; then
    ok "Polkit rule already exists — skipping."
else
    info "Writing polkit rule to $POLKIT_RULE_FILE ..."
    sudo tee "$POLKIT_RULE_FILE" > /dev/null << 'POLKIT_EOF'
// Allow users in the wheel group to mount/unmount drives without password.
// This is required for file managers (Thunar, Nautilus, Dolphin) to work
// on standalone Wayland compositors like Hyprland.
polkit.addRule(function(action, subject) {
    var mountActions = [
        "org.freedesktop.udisks2.filesystem-mount",
        "org.freedesktop.udisks2.filesystem-mount-system",
        "org.freedesktop.udisks2.filesystem-unmount-others",
        "org.freedesktop.udisks2.encrypted-unlock",
        "org.freedesktop.udisks2.eject-media",
        "org.freedesktop.udisks2.power-off-drive"
    ];
    if (mountActions.indexOf(action.id) !== -1 && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKIT_EOF
    sudo systemctl restart polkit 2>/dev/null || true
    ok "Polkit rule created and polkit restarted."
fi

# ═════════════════════════════════════════════════════════════════════════════
# [3] Install FiraCode Nerd Font
# ═════════════════════════════════════════════════════════════════════════════
step "Installing FiraCode Nerd Font"

NERD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
FONT_DIR="$HOME/.local/share/fonts"
FONT_MARKER="$FONT_DIR/FiraCodeNerdFont-Regular.ttf"

if [ -f "$FONT_MARKER" ]; then
    ok "FiraCode Nerd Font already installed."
elif fc-list 2>/dev/null | grep -qi "FiraCode.*Nerd"; then
    ok "FiraCode Nerd Font already installed (fontconfig)."
else
    info "Downloading FiraCode Nerd Font from GitHub..."
    mkdir -p "$FONT_DIR"
    if curl -fSL --retry 3 --retry-delay 5 -o /tmp/FiraCode.zip "$NERD_URL"; then
        info "Extracting to $FONT_DIR ..."
        unzip -q -o /tmp/FiraCode.zip -d "$FONT_DIR" -x "*.otf" "LICENSE" "readme.md" 2>/dev/null || \
            unzip -q -o /tmp/FiraCode.zip -d "$FONT_DIR"
        rm -f /tmp/FiraCode.zip
        info "Updating font cache..."
        fc-cache -f 2>/dev/null || warn "Font cache update failed (non-fatal)"
        if [ -f "$FONT_MARKER" ]; then
            ok "FiraCode Nerd Font installed."
        else
            warn "Font extracted but not detected. Try: fc-cache -f"
        fi
    else
        warn "Download failed (check network). You may need to install FiraCode Nerd Font manually."
    fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# [4] Bluetooth — service + rfkill permissions
# ═════════════════════════════════════════════════════════════════════════════
step "Configuring Bluetooth"

# bluetoothd must be running, otherwise bluetui exits immediately.
if command -v bluetoothctl &>/dev/null || [ -f /usr/lib/systemd/system/bluetooth.service ]; then
    if systemctl is-enabled bluetooth.service &>/dev/null; then
        ok "bluetooth.service already enabled."
    else
        info "Enabling bluetooth.service ..."
        sudo systemctl enable --now bluetooth.service || \
            warn "Could not enable bluetooth.service — enable it manually."
    fi
fi

# Some adapters (e.g. MediaTek MT7921) come up rfkill soft-blocked after a
# cold boot. rfkill unblock needs root, so let wheel users toggle rfkill
# without a password and clear the soft block at login via a user service.
RFKILL_RULE_FILE="/etc/polkit-1/rules.d/10-rfkill-allow-wheel.rules"
if [ -f "$RFKILL_RULE_FILE" ]; then
    ok "rfkill polkit rule already exists — skipping."
else
    info "Allowing wheel group to use rfkill without password ..."
    sudo tee "$RFKILL_RULE_FILE" > /dev/null << 'RFKILL_EOF'
// Allow users in the wheel group to toggle rfkill (WiFi/Bluetooth) without
// a password. Required so the login service can clear soft-blocks.
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.rfkill" && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
RFKILL_EOF
    sudo systemctl restart polkit 2>/dev/null || true
    ok "rfkill polkit rule created."
fi

# ═════════════════════════════════════════════════════════════════════════════
# [5] Set up directories
# ═════════════════════════════════════════════════════════════════════════════
step "Setting up directories"

mkdir -p "$HOME/.config/systemd/user/graphical-session.target.wants"
mkdir -p "$HOME/.config/hypr/colors"
mkdir -p "$HOME/.config/waybar/colors"
mkdir -p "$HOME/.config/kitty/colors"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Pictures"
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" <<'EOF'
[Icon Theme]
Inherits=breeze_cursors
EOF
ok "Directories and icon theme ready."

# ═════════════════════════════════════════════════════════════════════════════
# [6] Deploy config files
# ═════════════════════════════════════════════════════════════════════════════
step "Deploying config files"

for app in hypr waybar rofi kitty ghostty fish nvim fastfetch btop scripts gtk-3.0 Thunar swaync opencode; do
    src="$DOTFILES/config/$app"
    dst="$HOME/.config/$app"
    if [ -d "$src" ]; then
        # opencode's config dir may already exist with user data (auth, plugins,
        # node_modules); link the files we own instead of replacing the dir.
        if [ "$app" = "opencode" ]; then
            mkdir -p "$dst/plugins" "$dst/prompts"
            for f in "$src"/*.md "$src"/*.jsonc "$src"/*.json; do
                [ -f "$f" ] || continue
                deploy_link "$f" "$dst/$(basename "$f")"
            done
            for f in "$src/plugins/"* "$src/prompts/"*; do
                [ -f "$f" ] || continue
                deploy_link "$f" "$dst/$(basename "$(dirname "$f")")/$(basename "$f")"
            done
        else
            deploy_link "$src" "$dst"
        fi
    fi
done

# Ensure all scripts are executable
chmod +x "$HOME/.config/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/rofi/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/scripts/swaync/"*.sh 2>/dev/null || true
ok "Scripts marked executable."

# Standalone files
for f in starship.toml; do
    src="$DOTFILES/config/$f"
    dst="$HOME/.config/$f"
    if [ -f "$src" ]; then
        deploy_link "$src" "$dst"
    fi
done

# Systemd user services
for f in "$DOTFILES"/config/systemd/user/graphical-session.target.wants/*; do
    [ -e "$f" ] || continue
    name="$(basename "$f")"
    target="$HOME/.config/systemd/user/graphical-session.target.wants/$name"
    # Skip dangling links (e.g. vicinae.service points at /usr/local/...)
    if [ -L "$f" ] && [ ! -e "$f" ]; then
        rm -f "$target"
        continue
    fi
    ln -sf "$f" "$target"
    # The wants/ dir alone is not enough for `systemctl enable`; the unit must
    # also be discoverable directly under user/.
    ln -sf "$f" "$HOME/.config/systemd/user/$name"
done
ok "Systemd user service symlinks created."

# fumon (uwsm's unit failure notifier) is replaced by agent-watch.service,
# which adds clickable "debug with AI" actions. Mask it so both don't fire.
if [ -f "$HOME/.config/systemd/user/agent-watch.service" ]; then
    systemctl --user mask fumon.service >/dev/null 2>&1 || true
    systemctl --user stop fumon.service >/dev/null 2>&1 || true
    systemctl --user daemon-reload >/dev/null 2>&1 || true
    systemctl --user enable agent-watch.service >/dev/null 2>&1 || true
    ok "agent-watch enabled; fumon masked."
fi

# Binaries
if [ -d "$DOTFILES/bin" ]; then
    cp -rn "$DOTFILES/bin/"* "$HOME/.local/bin/" 2>/dev/null || true
    ok "Binaries installed (bluetui, impala-nm)."
fi

# ── AI coding agents ──
# opencode is the desktop's primary agent (SUPER+R → AI Agents, error → debug
# flow). Install it if missing; other agents are installed on demand from the
# launcher via agent-manager.sh.
if ! command -v opencode &>/dev/null; then
    info "Installing opencode (primary AI agent)..."
    if curl -fsSL https://opencode.ai/install | bash; then
        ok "opencode installed."
    else
        warn "opencode install failed — retry from: SUPER+R → AI Agents"
    fi
else
    ok "opencode already installed ($(opencode --version 2>/dev/null | head -1))."
fi

# Sanity-check bluetui: it exits instantly when the adapter is rfkill
# soft-blocked or bluetoothd is down, which looks like the window
# auto-closing. Surface the real reason at install time.
if [ -x "$HOME/.local/bin/bluetui" ] && ! "$HOME/.local/bin/bluetui" --help >/dev/null 2>&1; then
    warn "bluetui failed to start — see the error above (likely rfkill soft-blocked)."
fi

# ═════════════════════════════════════════════════════════════════════════════
# [7] Set up theme defaults (Catppuccin-Dark)
# ═════════════════════════════════════════════════════════════════════════════
step "Setting up theme defaults (Catppuccin-Dark)"

# Hyprland border color
ln -sf "$HOME/.config/hypr/colors/Catppuccin-Dark.lua"   "$HOME/.config/hypr/colors/current.lua"
# Waybar CSS color variables
ln -sf "$HOME/.config/waybar/colors/Catppuccin-Dark.css"  "$HOME/.config/waybar/colors/current.css"
# Kitty terminal colors
ln -sf "$HOME/.config/kitty/colors/Catppuccin-Dark.conf"  "$HOME/.config/kitty/colors.conf"
# swaync panel colors — relative link inside the symlinked swaync dir
ln -sf "Catppuccin-Dark.css" "$HOME/.config/swaync/colors/current.css"
# Rofi theme colors — consumed by @import in rofi/config.rasi
ln -sf "Catppuccin-Dark.rasi" "$HOME/.config/rofi/colors/current.rasi"
ok "Theme defaults set."

# ═════════════════════════════════════════════════════════════════════════════
# [8] Deploy Wallpapers
# ═════════════════════════════════════════════════════════════════════════════
step "Deploying wallpapers"

WALLPAPERS_SRC="$DOTFILES/Pictures/Wallpapers"
WALLPAPERS_DST="$HOME/Pictures/Wallpapers"

if [ -d "$WALLPAPERS_SRC" ]; then
    if [ ! -e "$WALLPAPERS_DST" ] || [ ! -L "$WALLPAPERS_DST" ]; then
        backup "$WALLPAPERS_DST"
        rm -rf "$WALLPAPERS_DST"
    fi
    ln -sf "$WALLPAPERS_SRC" "$WALLPAPERS_DST"
    ok "Wallpapers linked."
fi

# ═════════════════════════════════════════════════════════════════════════════
# [9] Enable systemd services
# ═════════════════════════════════════════════════════════════════════════════
step "Enabling systemd user services"

systemctl --user daemon-reload 2>/dev/null || true

if command -v awww-daemon &>/dev/null; then
    info "awww-daemon will be started by Hyprland on login (hl.exec_cmd in hyprland.lua)."
fi

if [ -f "$HOME/.config/systemd/user/graphical-session.target.wants/vicinae.service" ]; then
    warn "Stale vicinae.service link found — removing (vicinae is no longer used)."
    rm -f "$HOME/.config/systemd/user/graphical-session.target.wants/vicinae.service"
fi
rm -f "$HOME/.config/systemd/user/vicinae.service" 2>/dev/null || true

# ═════════════════════════════════════════════════════════════════════════════
# [10] GTK theme (Catppuccin-Dark for GTK3/GTK4 apps)
# ═════════════════════════════════════════════════════════════════════════════
step "Installing Catppuccin GTK theme"

GTK_THEME_DIR="$HOME/.themes/catppuccin-macchiato-mauve-standard+default"
GTK_URL="https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-macchiato-mauve-standard+default.zip"

if [ -d "$GTK_THEME_DIR" ]; then
    ok "Catppuccin GTK theme already installed."
elif curl -fSL --retry 3 --retry-delay 5 -o /tmp/cat-gtk.zip "$GTK_URL"; then
    mkdir -p "$HOME/.themes"
    unzip -q -o /tmp/cat-gtk.zip -d /tmp/cat-gtk-extract
    cp -r "/tmp/cat-gtk-extract/catppuccin-macchiato-mauve-standard+default" "$HOME/.themes/"
    rm -rf /tmp/cat-gtk.zip /tmp/cat-gtk-extract
    ok "Catppuccin GTK theme installed."
else
    warn "GTK theme download failed — install manually from github.com/catppuccin/gtk"
fi

# ═════════════════════════════════════════════════════════════════════════════
# Done
# ═════════════════════════════════════════════════════════════════════════════
if [ "$_backup_created" -eq 1 ]; then
    printf "\n${DIM}Backups saved to: %s${NC}\n" "$BACKUP_DIR"
fi

[ -t 1 ] && printf '\033[2J\033[H'
banner "${GREEN}"

printf "${BOLD}${GREEN}✔ Installation complete!${NC}\n"
printf "\n${BOLD}Next steps:${NC}\n"
printf "  ${CYAN}1.${NC} Run wallpaper picker to activate theme engine:\n"
printf "     ${DIM}~/.config/scripts/bgselector.sh${NC}\n"
printf "  ${CYAN}2.${NC} Or set a wallpaper directly:\n"
printf "     ${DIM}awww img ~/Pictures/Wallpapers/Catppuccin/Dark/example.png -t fade${NC}\n"
printf "  ${CYAN}3.${NC} Log out and select Hyprland from your display manager.\n"
printf "\n${DIM}Enjoy your Hyprland setup!${NC}\n"
