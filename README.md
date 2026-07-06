# fedora-hyprland

Personal dotfiles for Hyprland on Fedora Linux.

## Overview

| Component | Choice | Notes |
|---|---|---|
| Window Manager | Hyprland | Lua config, wayland-native |
| Status Bar | Waybar | Catppuccin-themed, hover animations |
| Launcher | Rofi | drun/run/filebrowser/window modes |
| Wallpaper Picker | Custom Rofi + awww | Thumbnail preview, parallel generation |
| Terminal | Kitty (primary) + Ghostty (secondary) | Theme-synced colors |
| Shell | Fish | eza, bat, rg, fd, zoxide, delta |
| Prompt | Starship | Minimal git-aware prompt |
| Editor | Neovim (LazyVim) | Auto theme sync from wallpaper |
| System Info | Fastfetch | Custom ASCII logo |
| System Monitor | Btop | Braille graphs, CPU freq/temp |
| File Manager | Thunar | Custom "Open Terminal Here" action |
| GTK Theme | Catppuccin-Dark | WhiteSur-dark icons, breeze cursors |
| Qt Theme | Kvantum MacTahoeDark | Consistent with GTK |

## Features

### Theme Engine

Wallpaper-based theme sync across all components. The wallpaper path determines which color scheme is used.

```
Pictures/Wallpapers/<Theme>/<Variant>/<wallpaper>
```

Changing a wallpaper via `bgselector.sh` triggers `theme-sync.sh`, which applies matching colors to:

- Hyprland (active window border)
- Waybar (bar background, text, accent colors)
- Kitty (terminal color scheme)
- Neovim (colorscheme + transparency)

Supported themes: Catppuccin, Gruvbox, Nord, Everforest, Dracula, Material, Osaka, Rose-Pine (each with Dark/Light variants where available).

### Keybindings (Hyprland)

| Key | Action |
|---|---|
| Super + Q | Open terminal (kitty) |
| Super + C | Close focused window |
| Super + E | Open file manager (thunar) |
| Super + R | Open app launcher (vicinae) |
| Super + W | Open wallpaper picker |
| Super + V | Toggle window float |
| Super + S | Toggle scratchpad |
| Super + Arrows | Move focus |
| Super + 1-0 | Switch workspace |
| Super + Shift + 1-0 | Move window to workspace |
| Super + mouse drag | Move/resize window |
| Print | Flameshot screenshot |
| XF86Audio* | Volume/media/brightness keys |
| Super + mouse scroll | Scroll workspaces |

### Wallpaper Picker

`~/.config/scripts/bgselector.sh` is a custom wallpaper selector that:

- Scans `~/Pictures/Wallpapers/` recursively for images
- Generates thumbnails in parallel using ImageMagick (all CPU cores)
- Displays wallpapers in a Rofi grid (7 columns, 330x540 thumbnails)
- Applies selected wallpaper via `awww` with fade transition
- Automatically syncs theme based on wallpaper path

### Waybar Modules

Left: Workspaces, Window title
Center: Clock
Right: CPU, Memory, PulseAudio, Bluetooth, Network, Power Profiles, Battery, System Tray

Pre-compiled binaries included:

- `bluetui` (3.3 MB) -- Bluetooth TUI client
- `impala-nm` (4.6 MB) -- NetworkManager TUI client

Both are Rust binaries, dynamically linked, copied to `~/.local/bin/` during install.

## Installation

```bash
git clone https://github.com/alertxsto/fedora-hyprland ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:

1. Backup existing config directories to `.bak`
2. Symlink all configs from the repo to `~/.config/`
3. Copy wallpaper collection to `~/Pictures/Wallpapers/`
4. Install pre-compiled binaries to `~/.local/bin/`
5. Create default theme symlinks (Catppuccin-Dark)

After installation, run the wallpaper picker to activate the theme engine:

```bash
~/.config/scripts/bgselector.sh
```

### Dependencies

**Runtime:**

- hyprland (WM)
- waybar (bar)
- rofi (launcher)
- kitty (terminal)
- awww (wallpaper daemon)
- swaync or mako (notifications, if needed)
- pipewire + wireplumber (audio)
- playerctl (media keys)
- brightnessctl (backlight)
- flameshot (screenshots)
- fastfetch (system info)
- btop (system monitor)
- ImageMagick (thumbnail generation, used by bgselector)

**Recommended:**

- eza, bat, ripgrep, fd, zoxide, delta (fish aliases)
- FiraCode Nerd Font (terminal and waybar)
- JetBrainsMono Nerd Font (rofi)
- Papirus icon theme (rofi icons)
- Catppuccin GTK theme
- WhiteSur-dark icon theme

## Project Structure

```
dotfiles/
├── bin/                          # Pre-compiled Rust binaries
│   ├── bluetui
│   └── impala-nm
├── config/
│   ├── hypr/                     # Hyprland config + theme colors
│   │   ├── hyprland.lua
│   │   └── colors/*.lua
│   ├── waybar/                   # Waybar config + theme colors
│   │   ├── config.jsonc
│   │   ├── style.css
│   │   └── colors/*.css
│   ├── rofi/                     # Rofi launcher + wallpaper picker
│   │   ├── config.rasi
│   │   ├── bgselector/style.rasi
│   │   └── colors/wallust.rasi
│   ├── kitty/                    # Kitty terminal + theme colors
│   │   ├── kitty.conf
│   │   └── colors/*.conf
│   ├── ghostty/config.ghostty
│   ├── fish/                     # Fish shell config
│   │   ├── config.fish
│   │   └── conf.d/omf.fish
│   ├── starship.toml
│   ├── nvim/                     # Neovim (LazyVim) + auto theme
│   │   ├── init.lua
│   │   └── lua/
│   ├── fastfetch/                # System info
│   │   ├── config.jsonc
│   │   └── logo.txt
│   ├── btop/btop.conf
│   ├── scripts/                  # Theme engine
│   │   ├── bgselector.sh
│   │   └── theme-sync.sh
│   ├── gtk-3.0/settings.ini
│   ├── Thunar/uca.xml
│   └── systemd/user/             # User services
├── Pictures/Wallpapers/          # Wallpaper collection (237 MB)
│   ├── Catppuccin/Dark/
│   ├── Catppuccin/Light/
│   ├── Gruvbox/Dark/
│   ├── Nord/Dark/
│   └── ...
├── install.sh                    # Bootstrap script
└── README.md
```

## Unmanaged Files

The following are excluded from the repo (generated or session-specific):

- `hypr/colors/current.lua` -- symlink managed by theme-sync
- `waybar/colors/current.css` -- symlink managed by theme-sync
- `kitty/colors.conf` -- symlink managed by theme-sync
- `fish/fish_variables` -- session-specific
- `nvim/lazy-lock.json` -- lock file
- `nvim/.neoconf.json` -- project config
- `gtk-3.0/colors.css` -- generated by KDE
- KDE Plasma configs, browser profiles, dconf database
