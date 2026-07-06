<svg xmlns="http://www.w3.org/2000/svg" width="800" height="400" viewBox="0 0 800 400">
  <!-- Background -->
  <rect width="800" height="400" fill="#1e1e2e" rx="12"/>
  <!-- Accent bar -->
  <rect x="0" y="0" width="800" height="6" fill="#c6a0f6"/>
  <!-- Title -->
  <text x="400" y="100" text-anchor="middle" font-family="monospace" font-size="36" font-weight="bold" fill="#cdd6f4">󰖷 fedora-hyprland</text>
  <!-- Subtitle -->
  <text x="400" y="140" text-anchor="middle" font-family="monospace" font-size="16" fill="#a6adc8">Hyprland dotfiles — Fedora / openSUSE</text>
  <!-- Feature badges -->
  <rect x="120" y="190" width="130" height="40" rx="8" fill="#313244"/>
  <text x="185" y="216" text-anchor="middle" font-family="monospace" font-size="13" fill="#89b4fa">Hyprland 󰖷</text>
  <rect x="265" y="190" width="130" height="40" rx="8" fill="#313244"/>
  <text x="330" y="216" text-anchor="middle" font-family="monospace" font-size="13" fill="#a6e3a1">Waybar </text>
  <rect x="410" y="190" width="130" height="40" rx="8" fill="#313244"/>
  <text x="475" y="216" text-anchor="middle" font-family="monospace" font-size="13" fill="#f9e2af">Rofi </text>
  <rect x="555" y="190" width="130" height="40" rx="8" fill="#313244"/>
  <text x="620" y="216" text-anchor="middle" font-family="monospace" font-size="13" fill="#f38ba8">Kitty </text>
  <!-- Theme engine highlight -->
  <rect x="100" y="260" width="600" height="100" rx="10" fill="#181825" stroke="#c6a0f6" stroke-width="1.5"/>
  <text x="400" y="290" text-anchor="middle" font-family="monospace" font-size="15" font-weight="bold" fill="#c6a0f6"> Theme Engine</text>
  <text x="400" y="315" text-anchor="middle" font-family="monospace" font-size="12" fill="#bac2de">Wallpaper → Auto-sync colors to Hyprland · Waybar · Kitty · Neovim</text>
  <text x="400" y="340" text-anchor="middle" font-family="monospace" font-size="11" fill="#585b70">8 themes · Dark/Light variants · 230+ wallpapers</text>
</svg>

# fedora-hyprland

Personal dotfiles for **Hyprland** on Fedora Linux (also works on openSUSE).  
Wallpaper-driven theme engine that auto-syncs colors across your entire desktop.

> **Live preview** — bar on top, clean borders, zero rounding, full-width transparency.

##  Theme Engine

Pick a wallpaper → colors auto-sync everywhere.

```
Pictures/Wallpapers/<Theme>/<Variant>/<wallpaper>
```

| Component | What syncs |
|-----------|-----------|
| **Hyprland** | Active window border color |
| **Waybar** | Background, text, accent, surface |
| **Kitty** | Terminal color scheme |
| **Neovim** | Colorscheme + transparency |

### Supported themes

| Theme | Dark | Light |
|-------|------|-------|
| Catppuccin |  |  |
| Gruvbox |  |  |
| Nord |  |  |
| Material |  |  |
| Everforest |  | — |
| Dracula |  | — |
| Osaka |  | — |
| Rose-Pine |  | — |

**230+ wallpapers** included across all themes and variants.

##  Waybar

| Position | Modules |
|----------|---------|
| **Left** | Workspaces · Window title |
| **Center** | Clock ( HH:MM  DD Mon) |
| **Right** | CPU  · Memory  · PulseAudio  · Bluetooth  · Network  · Power  · Battery  · Tray |

- **Height**: 38px · **Font**: 14px FiraCode Nerd Font
- Smooth hover animations, color transitions
- Theme-aware via `colors/current.css`

##  Wallpaper Picker

`~/.config/scripts/bgselector.sh` — custom Rofi-based thumbnail browser.

```
Super + W      Launch wallpaper picker
```

- Scans `~/Pictures/Wallpapers/` recursively
- Generates thumbnails in parallel (all CPU cores via ImageMagick)
- 7-column grid, 330×540 thumbnails
- Applies wallpaper via `awww` with fade transition
- Triggers `theme-sync.sh` automatically

##  Keybindings

| Key | Action |
|-----|--------|
| `Super + Q` | Open terminal (kitty) |
| `Super + C` | Close window |
| `Super + E` | Open file manager (Thunar) |
| `Super + R` | App launcher (rofi) |
| `Super + W` | **Wallpaper picker** |
| `Super + V` | Toggle float |
| `Super + S` | Scratchpad (special workspace) |
| `Super + arrows` | Move focus |
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move window to workspace |
| `Super + mouse drag` | Move / resize window |
| `Print` | Flameshot screenshot |
| `XF86Audio*` | Volume · Media · Brightness |

##  Components

| Component | Choice | Notes |
|-----------|--------|-------|
| WM | **Hyprland** | Lua config, wayland-native |
| Bar | **Waybar** | Catppuccin-themed, animated |
| Launcher | **Rofi** | drun/run/window modes |
| Terminal | **Kitty** + Ghostty | Theme-synced |
| Shell | **Fish** | eza, bat, rg, fd, zoxide, delta |
| Prompt | **Starship** | Minimal git-aware |
| Editor | **Neovim** (LazyVim) | Auto theme sync |
| System Info | **Fastfetch** | Custom ASCII logo |
| Monitor | **Btop** | Braille graphs |
| FM | **Thunar** | Custom open-here action |
| GTK | **Catppuccin-Dark** | WhiteSur icons, breeze cursors |
| Qt | **Kvantum MacTahoeDark** | Matches GTK |

##  Installation

```bash
git clone https://github.com/alertxsto/fedora-hyprland ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:

1. Install required packages (dnf / zypper)
2. Install FiraCode Nerd Font
3. Create directory structure
4. **Symlink** all configs to `~/.config/`
5. Set default theme (Catppuccin-Dark)
6. **Link wallpapers** to `~/Pictures/Wallpapers/`
7. Set up cursor theme (`breeze_cursors`)
8. Enable systemd user services

Then activate the theme engine:

```bash
~/.config/scripts/bgselector.sh
```

Or set one directly:

```bash
awww img ~/Pictures/Wallpapers/Catppuccin/Dark/example.png -t fade
```

### Dependencies

**Runtime** — `hyprland waybar rofi kitty fish starship fastfetch btop neovim thunar`  
**Audio** — `pipewire wireplumber playerctl`  
**Hardware** — `brightnessctl`  
**Graphics** — `ImageMagick` (thumbnail gen)  
**Shell** — `eza bat ripgrep fd zoxide git-delta`  

All auto-installed on Fedora. On openSUSE, `awww` needs manual cargo install:

```bash
cargo install awww
```

### Cursor

Cursor theme is set at three levels:

1. **gtk-3.0** — `gsettings` / `settings.ini`
2. **Hyprland** — `XCURSOR_THEME` env + `hyprctl setcursor`
3. **Fallback** — `~/.icons/default/index.theme`

All point to `breeze_cursors` (size 24).

##  Project Structure

```
dotfiles/
├── bin/                          # Pre-compiled Rust binaries
│   ├── bluetui                   # Bluetooth TUI
│   └── impala-nm                 # NetworkManager TUI
├── config/
│   ├── hypr/                     # Hyprland + theme colors
│   ├── waybar/                   # Bar + theme colors
│   ├── rofi/                     # Launcher + bgselector
│   ├── kitty/                    # Terminal + theme colors
│   ├── ghostty/
│   ├── fish/                     # Shell config
│   ├── starship.toml
│   ├── nvim/                     # LazyVim + auto theme
│   ├── fastfetch/                # System info
│   ├── btop/
│   ├── scripts/                  # Theme engine
│   │   ├── bgselector.sh
│   │   └── theme-sync.sh
│   ├── gtk-3.0/
│   ├── Thunar/
│   └── systemd/user/
├── Pictures/Wallpapers/          # 230+ wallpapers
├── install.sh                    # Bootstrap
└── README.md
```

##  Unmanaged

These are generated at runtime and **not** tracked:

- `hypr/colors/current.lua`
- `waybar/colors/current.css`
- `kitty/colors.conf`
- `fish/fish_variables`
- `nvim/lazy-lock.json`
- `gtk-3.0/colors.css`

---

<p align="center">
  <sub>Hyprland · Fedora · Catppuccin · Lua config · Rofi · KDE cursor · awww</sub>
</p>
