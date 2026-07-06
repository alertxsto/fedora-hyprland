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
elif [ -f /etc/os-release ] && grep -qi "suse\|opensuse" /etc/os-release; then
    DISTRO="opensuse"
    PKG_MGR="zypper"
else
    die "Unsupported distro. Only Fedora and openSUSE are supported."
fi
ok "Detected: ${DISTRO}"

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
    hyprland waybar rofi kitty fish
    starship fastfetch btop
    ImageMagick pipewire wireplumber
    playerctl brightnessctl flameshot
    eza bat ripgrep fd-find zoxide git-delta
    papirus-icon-theme jetbrains-mono-fonts-all
)

OPENSUSE_PKGS=(
    hyprland waybar rofi kitty fish
    starship fastfetch btop
    ImageMagick pipewire wireplumber
    playerctl brightnessctl flameshot
    eza bat ripgrep fd zoxide git-delta
    papirus-icon-theme
)

case "$DISTRO" in
    fedora)
        sudo dnf install -y "${FEDORA_PKGS[@]}"
        ;;
    opensuse)
        sudo zypper install -y "${OPENSUSE_PKGS[@]}"
        sudo zypper install -y awww 2>/dev/null || warn "awww not in repos — install manually via cargo"
        ;;
esac

ok "Packages installed."

# ═════════════════════════════════════════════════════════════════════════════
# [2] Install FiraCode Nerd Font
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
# [3] Set up directories
# ═════════════════════════════════════════════════════════════════════════════
step "Setting up directories"

mkdir -p "$HOME/.config/systemd/user"
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
# [4] Deploy config files
# ═════════════════════════════════════════════════════════════════════════════
step "Deploying config files"

for app in hypr waybar rofi kitty ghostty fish nvim fastfetch btop scripts gtk-3.0 Thunar; do
    src="$DOTFILES/config/$app"
    dst="$HOME/.config/$app"
    if [ -d "$src" ]; then
        deploy_link "$src" "$dst"
    fi
done

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
    [ -f "$f" ] && ln -sf "$f" "$HOME/.config/systemd/user/graphical-session.target.wants/"
done
ok "Systemd user service symlinks created."

# Binaries
if [ -d "$DOTFILES/bin" ]; then
    cp -rn "$DOTFILES/bin/"* "$HOME/.local/bin/" 2>/dev/null || true
    ok "Binaries installed (bluetui, impala-nm)."
fi

# ═════════════════════════════════════════════════════════════════════════════
# [5] Set up theme defaults
# ═════════════════════════════════════════════════════════════════════════════
step "Setting up theme defaults (Catppuccin-Dark)"

ln -sf "$HOME/.config/hypr/colors/Catppuccin-Dark.lua"   "$HOME/.config/hypr/colors/current.lua"
ln -sf "$HOME/.config/waybar/colors/Catppuccin-Dark.css"  "$HOME/.config/waybar/colors/current.css"
ln -sf "$HOME/.config/kitty/colors/Catppuccin-Dark.conf"  "$HOME/.config/kitty/colors.conf"
ok "Theme defaults set."

# ═════════════════════════════════════════════════════════════════════════════
# [6] Deploy Wallpapers
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
# [7] Enable systemd services
# ═════════════════════════════════════════════════════════════════════════════
step "Enabling systemd user services"

systemctl --user daemon-reload 2>/dev/null || true

if [ -f "$HOME/.config/systemd/user/graphical-session.target.wants/vicinae.service" ]; then
    systemctl --user enable vicinae.service 2>/dev/null || true
    ok "vicinae.service enabled."
fi

if command -v awww-daemon &>/dev/null; then
    info "awww-daemon will be started by Hyprland on login (exec-once in hyprland.lua)."
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
