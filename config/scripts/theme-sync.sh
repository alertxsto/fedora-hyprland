#!/bin/bash

CACHE_FILE="$HOME/.cache/current-wallpaper"

# Get wallpaper path: argument > cache file > awww query
wallpaper_path=""
if [ -n "$1" ]; then
    wallpaper_path="$1"
elif [ -f "$CACHE_FILE" ]; then
    wallpaper_path=$(cat "$CACHE_FILE")
fi

# Save for later use
if [ -n "$wallpaper_path" ]; then
    echo "$wallpaper_path" > "$CACHE_FILE"
fi

if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    exit 0
fi

# Path structure: .../Theme/Variant/wallpaper.png
variant=$(echo "$wallpaper_path" | awk -F'/' '{print $(NF-1)}')
theme_name=$(echo "$wallpaper_path" | awk -F'/' '{print $(NF-2)}')

if [ -z "$theme_name" ] || [ "$theme_name" == "Wallpapers" ] || [ "$theme_name" == "Pictures" ]; then
    theme_name="Catppuccin"
    variant="Dark"
fi

WAYBAR_COLORS_DIR="$HOME/.config/waybar/colors"
HYPR_COLORS_DIR="$HOME/.config/hypr/colors"
KITTY_COLORS_DIR="$HOME/.config/kitty/colors"

THEME_FILE_ID="${theme_name}-${variant}"
WAYBAR_THEME="$WAYBAR_COLORS_DIR/$THEME_FILE_ID.css"
HYPR_THEME="$HYPR_COLORS_DIR/$THEME_FILE_ID.lua"
KITTY_THEME="$KITTY_COLORS_DIR/$THEME_FILE_ID.conf"

# Default fallback colors
BASE="#24273a"
TEXT="#cad3f5"
ACCENT="#c6a0f6"
GREEN="#a6da95"
YELLOW="#eed49f"
RED="#ed8796"
BLUE="#8aadf4"
SURFACE="#5b6078"

# Exact palettes based on Theme and Variant
if [ "$theme_name" == "Catppuccin" ]; then
    if [ "$variant" == "Light" ]; then
        BASE="#eff1f5"; TEXT="#4c4f69"; ACCENT="#8839ef"; GREEN="#40a02b"; YELLOW="#df8e1d"; RED="#d20f39"; BLUE="#1e66f5"; SURFACE="#acb0be"
    else
        BASE="#24273a"; TEXT="#cad3f5"; ACCENT="#c6a0f6"; GREEN="#a6da95"; YELLOW="#eed49f"; RED="#ed8796"; BLUE="#8aadf4"; SURFACE="#5b6078"
    fi
elif [ "$theme_name" == "Gruvbox" ]; then
    if [ "$variant" == "Light" ]; then
        BASE="#fbf1c7"; TEXT="#3c3836"; ACCENT="#b57614"; GREEN="#98971a"; YELLOW="#d79921"; RED="#cc241d"; BLUE="#458588"; SURFACE="#d5c4a1"
    else
        BASE="#282828"; TEXT="#ebdbb2"; ACCENT="#fabd2f"; GREEN="#b8bb26"; YELLOW="#fabd2f"; RED="#fb4934"; BLUE="#83a598"; SURFACE="#504945"
    fi
elif [ "$theme_name" == "Nord" ]; then
    if [ "$variant" == "Light" ]; then
        BASE="#eceff4"; TEXT="#2e3440"; ACCENT="#5e81ac"; GREEN="#8fbcbb"; YELLOW="#ebcb8b"; RED="#bf616a"; BLUE="#81a1c1"; SURFACE="#d8dee9"
    else
        BASE="#2e3440"; TEXT="#d8dee9"; ACCENT="#88c0d0"; GREEN="#a3be8c"; YELLOW="#ebcb8b"; RED="#bf616a"; BLUE="#81a1c1"; SURFACE="#434c5e"
    fi
elif [ "$theme_name" == "Everforest" ]; then
    BASE="#2b3339"; TEXT="#d3c6aa"; ACCENT="#a7c080"; GREEN="#a7c080"; YELLOW="#dbbc7f"; RED="#e67e80"; BLUE="#7fbbb3"; SURFACE="#4a555b"
elif [ "$theme_name" == "Dracula" ]; then
    BASE="#282a36"; TEXT="#f8f8f2"; ACCENT="#bd93f9"; GREEN="#50fa7b"; YELLOW="#f1fa8c"; RED="#ff5555"; BLUE="#8be9fd"; SURFACE="#44475a"
elif [ "$theme_name" == "Material" ]; then
    if [ "$variant" == "Light" ]; then
        BASE="#fafafa"; TEXT="#000000"; ACCENT="#39adb5"; GREEN="#91b859"; YELLOW="#f6a434"; RED="#e53935"; BLUE="#39adb5"; SURFACE="#e0e0e0"
    else
        BASE="#212121"; TEXT="#eeffff"; ACCENT="#82aaff"; GREEN="#c3e88d"; YELLOW="#ffcb6b"; RED="#f07178"; BLUE="#82aaff"; SURFACE="#424242"
    fi
elif [ "$theme_name" == "Osaka" ]; then
    BASE="#1f1f28"; TEXT="#dcd7ba"; ACCENT="#7e9cd8"; GREEN="#98bb6c"; YELLOW="#e6c384"; RED="#e82424"; BLUE="#7e9cd8"; SURFACE="#363646"
elif [ "$theme_name" == "Rose-Pine" ]; then
    BASE="#191724"; TEXT="#e0def4"; ACCENT="#c4a7e7"; GREEN="#31748f"; YELLOW="#f6c177"; RED="#eb6f92"; BLUE="#9ccfd8"; SURFACE="#26233a"
fi

if [ ! -f "$WAYBAR_THEME" ]; then
    cat > "$WAYBAR_THEME" <<EOF
@define-color base   ${BASE};
@define-color crust  ${BASE};
@define-color mantle ${BASE};
@define-color text   ${TEXT};
@define-color subtext0 ${SURFACE};
@define-color subtext1 ${SURFACE};
@define-color surface0 ${SURFACE};
@define-color surface1 ${SURFACE};
@define-color surface2 ${SURFACE};
@define-color lavender ${ACCENT};
@define-color blue     ${BLUE};
@define-color sapphire ${BLUE};
@define-color sky      ${BLUE};
@define-color teal     ${ACCENT};
@define-color green    ${GREEN};
@define-color yellow   ${YELLOW};
@define-color peach    ${YELLOW};
@define-color maroon   ${RED};
@define-color red      ${RED};
@define-color mauve    ${ACCENT};
@define-color pink     ${ACCENT};
@define-color flamingo ${ACCENT};
@define-color rosewater ${ACCENT};
EOF
fi

if [ ! -f "$HYPR_THEME" ]; then
    ACCENT_HEX="${ACCENT}ee"
    echo "return { active_border = \"rgba(${ACCENT_HEX:1})\" }" > "$HYPR_THEME"
fi

# Symlink
ln -sf "$WAYBAR_THEME" "$WAYBAR_COLORS_DIR/current.css"
ln -sf "$HYPR_THEME" "$HYPR_COLORS_DIR/current.lua"
ln -sf "$KITTY_THEME" "$HOME/.config/kitty/colors.conf"

# Reload Waybar CSS (hot reload)
killall -SIGUSR2 waybar

# Reload Hyprland config
hyprctl reload

# Reload Kitty (all instances)
killall -SIGUSR1 kitty 2>/dev/null
