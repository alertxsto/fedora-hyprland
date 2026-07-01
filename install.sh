#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

echo "Installing dotfiles..."

# Symlink config directories
for app in hypr waybar rofi kitty ghostty fish nvim fastfetch btop scripts gtk-3.0 Thunar; do
    src="$DOTFILES_DIR/config/$app"
    dst="$CONFIG_DIR/$app"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "Backing up $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    ln -sfn "$src" "$dst"
    echo "  Linked $app"
done

# Symlink standalone files
for f in starship.toml; do
    src="$DOTFILES_DIR/config/$f"
    dst="$CONFIG_DIR/$f"
    ln -sf "$src" "$dst"
    echo "  Linked $f"
done

# Systemd user services
mkdir -p "$CONFIG_DIR/systemd/user/graphical-session.target.wants"
for f in "$DOTFILES_DIR"/config/systemd/user/graphical-session.target.wants/*; do
    [ -f "$f" ] && ln -sf "$f" "$CONFIG_DIR/systemd/user/graphical-session.target.wants/"
done
echo "  Linked systemd user services"

# Wallpapers
if [ -d "$DOTFILES_DIR/Pictures/Wallpapers" ]; then
    mkdir -p "$WALLPAPER_DIR"
    cp -rn "$DOTFILES_DIR/Pictures/Wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null || true
    echo "  Wallpapers synced"
fi

# Ensure theme color directories exist (needed for theme-sync.sh)
mkdir -p "$CONFIG_DIR/hypr/colors" "$CONFIG_DIR/waybar/colors" "$CONFIG_DIR/kitty/colors"

# Create initial theme symlinks (default to Catppuccin-Dark)
ln -sf "$CONFIG_DIR/hypr/colors/Catppuccin-Dark.lua" "$CONFIG_DIR/hypr/colors/current.lua"
ln -sf "$CONFIG_DIR/waybar/colors/Catppuccin-Dark.css" "$CONFIG_DIR/waybar/colors/current.css"
ln -sf "$CONFIG_DIR/kitty/colors/Catppuccin-Dark.conf" "$CONFIG_DIR/kitty/colors.conf"

echo ""
echo "Dotfiles installed!"
echo "Run '~/.config/scripts/bgselector.sh' to set a wallpaper & auto-sync themes."
