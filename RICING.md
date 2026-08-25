# Ricing EndeavourOS - Caelestia Shell (Hyprland)

## System Specs
- **OS**: EndeavourOS x86_64
- **DE**: KDE Plasma 6.7.4-3 (Wayland) + Caelestia Shell 2.3.0
- **WM**: Hyprland 0.56.2 (Lua config)
- **Shell**: Quickshell 0.3.1
- **CLI**: caelestia-cli 1.1.3.dev27
- **CPU**: Intel i5-7200U (HD 620)
- **GPU**: NVIDIA GeForce 940MX (2GB)
- **RAM**: 11GB
- **Resolution**: 1366x768
- **Cursor**: Bibata-Modern-Ice

---

## Quick Commands

```bash
# Theme toggle
theme dark / theme light / theme toggle

# Wallpaper
caelestia wallpaper -f FILE       # set wallpaper + regen scheme
caelestia wallpaper -r ~/Pictures/Wallpapers/  # regen scheme from current
caelestia scheme set --mode dark  # force dark mode
caelestia scheme set --mode light # force light mode

# Shell
qs -c caelestia kill && setsid qs -c caelestia &  # restart shell

# SDDM cursor sync (runs automatically on scheme change)
~/.local/bin/sync-sddm-scheme
```

---

## Installed Components

### 1. Caelestia Shell (Hyprland)
Quickshell-based desktop shell: bar, launcher, dashboard, notifications, wallpaper manager.

**Config files (Lua-based):**
| File | Purpose |
|------|---------|
| `~/.config/hypr/hyprland.lua` | Entry point (symlink to dots) |
| `~/.local/state/caelestia/dots/hypr/` | Official dots (canonical config) |
| `~/.config/caelestia/hypr-user.lua` | User overrides (empty) |
| `~/.config/caelestia/shell.json` | Shell settings (transparency, clock, notifs) |
| `~/.config/caelestia/cli.json` | CLI settings (wallpaper postHook) |
| `~/.local/state/caelestia/scheme.json` | Current Material You color scheme |
| `~/.config/quickshell/caelestia/` | Shell QML source |

**Keybinds:**
| Key | Action |
|-----|--------|
| `Super` (hold) | Toggle launcher |
| `Super+K` | Toggle dashboard (showall) |
| `Super+Return` | Terminal (kitty) |
| `Super+Q` | Close window |
| `Super+E` | Dolphin file manager |
| `Super+S` | Sidebar |
| `Super+U` | Utilities |
| `Super+Shift+E` | Session menu |
| `Super+Shift+W` | Wallpaper picker |
| `Super+Escape` | Lock screen |
| `Print` | Screenshot fullscreen |
| `Shift+Print` | Screenshot freeze |
| `Ctrl+Print` | Screenshot region |
| `Super+1-9` | Switch workspace |
| `Super+Shift+1-9` | Move to workspace |

### 2. Material You Dynamic Colors
Wallpaper → warna desktop otomatis via Caelestia scheme system.

```bash
# Scheme auto-generated from wallpaper
caelestia wallpaper -r ~/Pictures/Wallpapers/  # regenerate
```

**Files:**
- `~/.local/state/caelestia/scheme.json` — dynamic scheme (dark + light)
- Applied to: bar, dashboard, lockscreen, notifications, SDDM

### 3. SDDM Theme
Custom simple-sddm with colors synced from wallpaper scheme.

```bash
~/.local/bin/sync-sddm-scheme  # sync colors from scheme.json
```

**Config:**
- `/usr/share/sddm/themes/simple-sddm/theme.conf` — colors, font, blur
- `/etc/sddm.conf.d/autologin.conf` — auto-login
- `/etc/sddm.conf.d/cursor.conf` — cursor theme (Bibata-Modern-Ice)

### 4. Klassy Window Decoration
Title bar minimal, customizable buttons.

**Config:**
- `~/.config/klassyrc` — button order: XIA, border size: VerySmall

### 5. Desktop Clock Widget
Digital clock on desktop background, bottom-right.

**Config in `shell.json`:**
```json
"desktopClock": {
    "enabled": true,
    "invertColors": true,
    "position": "bottom-right",
    "scale": 0.6,
    "background": { "enabled": true, "blur": true, "opacity": 0.85 }
}
```

---

## Transparency & Blur

**Config in `shell.json`:**
```json
"transparency": { "enabled": false, "base": 0.5, "layers": 0.48 }
```

**Hyprland blur settings:**
- `decoration:blur:ignore_opacity = true` — allows blur behind semi-transparent
- `decoration:blur:size = 16` (from variables.lua, default was 8)
- `decoration:blur:passes = 4` (from variables.lua, default was 2)
- `decoration:blur:noise = 0` — no grain texture
- `decoration:blur:vibrancy = 0.25`
- `ignore_alpha = 0.38` in rules.lua for `caelestia-(drawers|background)` layers

**Colours.qml ignore_alpha formula:**
```
Math.max(0, Math.min(transparency.base, transparency.layers) - 0.02)
```
Note: batchMessage silently fails (Hypr.usingLua is false), but static rules from rules.lua work.

---

## Lua Config Notes

**Hyprland 0.56 breaking changes:**
- `misc:vfr` → `debug:vfr`
- Global shortcuts on lone Super key broken
- `togglesplit` → `layoutmsg togglesplit`
- `hyprctl keyword` does NOT work with Lua config — use `hyprctl eval 'hl.config({...})'`

**Lua module cache:**
- `require("variables")` is cached at startup
- Editing `variables.lua` only takes effect after Hyprland restart
- `hyprctl reload` does NOT reload Lua modules

**Workarounds:**
- Launcher bind: patched `keybinds.lua` line 56 → `hl.dsp.exec_cmd("caelestia shell drawers toggle launcher")`
- Wallpaper picker: `SUPER+SHIFT+W` → `hl.dsp.exec_cmd("open-wallpaper-picker")`
- `~/.config/caelestia/hypr-user.lua` — empty file for user overrides

---

## Known Issues

- `Hypr.usingLua` always false in C++ plugin → Colours.qml batchMessage silently fails
- Static rules from rules.lua DO work (ignore_alpha = 0.38)
- `hyprctl keyword` doesn't work with Lua config parser
- Game mode detection: checks `Hypr.options["animations:enabled"] === 0` (currently OFF)
- Two Brave MPRIS players: metadata scoring in Players.qml picks richest metadata

---

## Key Files

| File | Purpose |
|------|---------|
| `~/.local/state/caelestia/dots/hypr/hyprland.lua` | Main Hyprland config |
| `~/.local/state/caelestia/dots/hypr/hyprland/keybinds.lua` | Keybinds (patched launcher + wallpaper picker) |
| `~/.local/state/caelestia/dots/hypr/hyprland/rules.lua` | Window/layer rules (blur, ignore_alpha) |
| `~/.local/state/caelestia/dots/hypr/hyprland/variables.lua` | Variables (browser, cursor, blur size/passes) |
| `~/.local/state/caelestia/dots/hypr/hyprland/decoration.lua` | Decoration (noise, vibrancy, ignore_opacity) |
| `~/.local/state/caelestia/dots/hypr/hyprland/misc.lua` | Misc (focus_on_activate=false) |
| `~/.config/caelestia/shell.json` | Shell settings |
| `~/.config/quickshell/caelestia/services/Colours.qml` | Color service (ignore_alpha formula) |
| `~/.config/quickshell/caelestia/services/Players.qml` | MPRIS player (metadata scoring) |
| `~/.config/quickshell/caelestia/modules/background/DesktopClock.qml` | Desktop clock widget |
| `~/.local/bin/sync-sddm-scheme` | SDDM color sync script |
| `~/.local/bin/open-wallpaper-picker` | Wallpaper picker launcher |
| `~/Pictures/Wallpapers/` | Wallpaper images |
| `~/.config/kcminputrc` | Cursor config |
| `~/.local/share/icons/Bibata-Modern-Ice/` | Cursor theme |
| `/etc/sddm.conf.d/cursor.conf` | SDDM cursor config |
