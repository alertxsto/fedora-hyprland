```
██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗
██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
         Hyprland dotfiles — Fedora / openSUSE
```

<div align="center">

![Hyprland](https://img.shields.io/badge/WM-Hyprland-89b4fa?style=for-the-badge&logo=wayland&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-supported-51a2da?style=for-the-badge&logo=fedora&logoColor=white)
![openSUSE](https://img.shields.io/badge/openSUSE-supported-73ba25?style=for-the-badge&logo=opensuse&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-cba6f7?style=for-the-badge)
![Wallpapers](https://img.shields.io/badge/wallpapers-90-f5c2e7?style=for-the-badge)

</div>

# 🌙 fedora-hyprland

Personal dotfiles for **Hyprland** on Fedora Linux (also works on openSUSE).
A wallpaper-driven theme engine that auto-syncs colors across your entire desktop.

> 🖼️ **Live preview** — floating island bar, blurred windows, soft shadows.

---

## 🎨 Theme Engine

Pick a wallpaper → colors auto-sync everywhere.

```
Pictures/Wallpapers/<Theme>/<Variant>/<wallpaper>
```

| Component | What syncs |
|-----------|-----------|
| 🪟 **Hyprland** | Active window border color |
| 📊 **Waybar** | Background, text, accent, surface |
| 💻 **Kitty** | Terminal color scheme |
| 👻 **Ghostty** | Terminal theme (reload via SIGUSR2) |
| 🔔 **SwayNC** | Notification cards, sliders, DND |
| 🚀 **Rofi** | Launcher + wallpaper picker |
| 📝 **Neovim** | Colorscheme + transparency |

### Supported themes

| Theme | Dark | Light |
|-------|:---:|:---:|
| Catppuccin | ✅ | ✅ |
| Gruvbox | ✅ | ✅ |
| Nord | ✅ | ✅ |
| Material | ✅ | ✅ |
| Everforest | ✅ | — |
| Dracula | ✅ | — |
| Osaka | ✅ | — |
| Rosé Pine | ✅ | — |

**🖼️ 90 wallpapers** included across all themes and variants.

---

## 📊 Waybar

| Position | Modules |
|----------|---------|
| ⬅️ **Left** | Workspaces · Window title |
| ⏺️ **Center** | Clock (🕐 HH:MM · 📅 DD Mon) |
| ➡️ **Right** | 🧠 CPU · 💾 Memory · 🔊 PulseAudio · 🔵 Bluetooth · 🌐 Network · ⏻ Power · 🔋 Battery · 📥 Tray |

- **Height:** 48px · **Font:** 13px FiraCode Nerd Font
- Smooth hover animations, color transitions
- Theme-aware via `colors/current.css`

---

## 🔍 Wallpaper Picker

`~/.config/scripts/bgselector.sh` — custom Rofi-based thumbnail browser.

```
Super + W      Launch wallpaper picker
```

- 📂 Scans `~/Pictures/Wallpapers/` recursively
- ⚡ Generates thumbnails in parallel (all CPU cores via ImageMagick)
- 🔳 7-column grid, 330×540 thumbnails
- 🌅 Applies wallpaper via `awww` with fade transition
- 🔄 Triggers `theme-sync.sh` automatically

---

## ⌨️ Keybindings

| Key | Action |
|-----|--------|
| `Super + Q` | 💻 Open terminal (kitty) |
| `Super + C` | ❌ Close window |
| `Super + E` | 📁 Open file manager (Thunar) |
| `Super + R` | 🚀 App launcher (rofi) |
| `Super + W` | 🖼️ **Wallpaper picker** |
| `Super + V` | 🪟 Toggle float |
| `Super + S` | 📌 Scratchpad (special workspace) |
| `Super + arrows` | 🎯 Move focus |
| `Super + 1-0` | 🔢 Switch workspace |
| `Super + Shift + 1-0` | 📤 Move window to workspace |
| `Super + mouse drag` | 🖱️ Move / resize window |
| `Print` | 📸 Flameshot screenshot |
| `XF86Audio*` | 🔊 Volume · Media · Brightness |

---

## 🧩 Components

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
| File Manager | **Thunar** | Custom open-here action |
| GTK | **Catppuccin-Dark** | WhiteSur icons, breeze cursors |
| Qt | **Kvantum MacTahoeDark** | Matches GTK |

---

## 📦 Installation

```bash
git clone https://github.com/alertxsto/fedora-hyprland ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:

1. 📥 Enable the required COPR repos (Fedora only — see below)
2. 📦 Install packages (dnf / zypper)
3. 🔤 Install FiraCode Nerd Font
4. 📁 Create directory structure
5. 🔗 **Symlink** all configs to `~/.config/`
6. 🎨 Set default theme (Catppuccin-Dark)
7. 🖼️ **Link wallpapers** to `~/Pictures/Wallpapers/`
8. 🖱️ Set up cursor theme (`breeze_cursors`)
9. 🎭 Install the Catppuccin GTK theme

Then activate the theme engine:

```bash
~/.config/scripts/bgselector.sh
```

Or set one directly:

```bash
awww img ~/Pictures/Wallpapers/Catppuccin/Dark/example.png -t fade
```

### 📦 COPR repos (Fedora)

Hyprland and friends are not in the Fedora repositories. The installer enables
these COPRs automatically:

| COPR | Provides |
|------|----------|
| `lionheartp/Hyprland` | hyprland, hyprpolkitagent, xdg-desktop-portal-hyprland, hyprshutdown, waybar-git, awww |
| `atim/starship` | starship prompt |
| `ponesicek/ghostty-bin` | ghostty terminal |

`waybar-git` is used instead of Fedora's `waybar` because the packaged version
predates Lua-based Hyprland configs. It `Obsoletes: waybar`, so the swap is clean.

### 📋 Dependencies

| Category | Packages |
|-----------|----------|
| **Runtime** | `hyprland waybar-git rofi kitty ghostty fish starship fastfetch btop neovim thunar exo` |
| **Wayland** | `xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent hyprland-guiutils hyprshutdown` |
| **Audio** | `pipewire wireplumber playerctl pavucontrol` |
| **Hardware** | `brightnessctl power-profiles-daemon` |
| **Graphics** | `ImageMagick` (thumbnail gen), `awww` (wallpaper) |
| **Shell** | `eza bat ripgrep fd zoxide git-delta` |
| **Desktop** | `SwayNotificationCenter libnotify wob` |

✅ Auto-installed on Fedora. On openSUSE, `hyprland` comes from the distro repo.

### 🖱️ Cursor

Cursor theme is set at three levels:

1. **gtk-3.0** — `gsettings` / `settings.ini`
2. **Hyprland** — `XCURSOR_THEME` env + `hyprctl setcursor`
3. **Fallback** — `~/.icons/default/index.theme`

All point to `breeze_cursors` (size 24).

### 🔵 Bluetooth

`bluetui` launches from the waybar Bluetooth module. Two things must be true or
it exits immediately (the window appears to auto-close in milliseconds):

1. `bluetooth.service` is running
2. the adapter is not rfkill soft-blocked

`install.sh` enables the service and grants the `wheel` group passwordless
`rfkill`, and `~/.config/scripts/rfkill-unblock.sh` clears any soft-block at
login. If the window still closes instantly, run `rfkill list bluetooth` to
check the block state.

---

## 🗂️ Project Structure

```
dotfiles/
├── bin/                          # Pre-compiled Rust binaries
│   ├── bluetui                   # Bluetooth TUI
│   └── impala-nm                 # NetworkManager TUI
├── config/
│   ├── hypr/                     # Hyprland (Lua) + theme colors
│   ├── waybar/                   # Floating island bar + theme colors
│   ├── rofi/                     # Launcher + bgselector (theme-synced)
│   ├── kitty/                    # Terminal + theme colors
│   ├── ghostty/                  # Terminal + theme file
│   ├── swaync/                   # Notification center + theme colors
│   ├── fish/                     # Shell config
│   ├── starship.toml
│   ├── nvim/                     # LazyVim + auto theme
│   ├── fastfetch/                # System info
│   ├── btop/
│   ├── scripts/                  # Theme engine
│   │   ├── bgselector.sh
│   │   ├── theme-sync.sh
│   │   ├── rfkill-unblock.sh
│   │   ├── volume.sh
│   │   ├── brightness.sh
│   │   └── wob-daemon.sh
│   ├── gtk-3.0/
│   └── Thunar/
├── Pictures/Wallpapers/          # 90 wallpapers
├── install.sh                    # Bootstrap
├── LICENSE
└── README.md
```

---

## ⚠️ Unmanaged

These are generated at runtime and **not** tracked:

- `hypr/colors/current.lua`
- `waybar/colors/current.css`
- `kitty/colors.conf`
- `swaync/colors/current.css`
- `rofi/colors/current.rasi`
- `ghostty/themes/current`
- `fish/fish_variables`
- `nvim/lazy-lock.json`
- `gtk-3.0/colors.css`

---

<p align="center">
  <sub>🐧 Hyprland · Fedora · Catppuccin · Lua config · Rofi · awww · swaync · wob</sub>
</p>
