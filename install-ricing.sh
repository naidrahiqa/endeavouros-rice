#!/bin/bash
# ═══════════════════════════════════════════════════════
#  🎨 Ethereal Night — Full KDE Ricing Installer
#  EndeavourOS KDE Plasma 6
# ═══════════════════════════════════════════════════════

set -e

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║                                              ║"
echo "  ║   🌙 Ethereal Night — KDE Ricing Installer   ║"
echo "  ║                                              ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# ── Phase 1: Install all packages ──────────────────
echo "  📦 [1/3] Installing packages..."
echo "  ─────────────────────────────────────────"
yay -S --noconfirm --needed \
    kvantum qt5ct qt6ct \
    papirus-icon-theme \
    klassy \
    btop cava

echo ""
echo "  ✅ All packages installed!"
echo ""

# ── Phase 2: Apply color scheme ────────────────────
echo "  🎨 [2/3] Applying Ethereal Night theme..."
echo "  ─────────────────────────────────────────"
plasma-apply-colorscheme EtherealNight 2>/dev/null && echo "  ✓ Color scheme applied" || echo "  ⚠ Color scheme will apply on next login"
plasma-apply-desktoptheme breeze-dark 2>/dev/null && echo "  ✓ Plasma style set" || true

# Apply icon theme via plasma
if command -v plasma-apply-icon-theme &>/dev/null; then
    plasma-apply-icon-theme Papirus-Dark 2>/dev/null && echo "  ✓ Icons set to Papirus-Dark" || true
fi

echo ""

# ── Phase 3: Reload KWin ──────────────────────────
echo "  🪟 [3/3] Reloading KWin..."
echo "  ─────────────────────────────────────────"
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null && echo "  ✓ KWin reloaded" || echo "  ⚠ KWin will reload on next login"

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║                                              ║"
echo "  ║   ✅ DONE! Sekarang log out & log in balik   ║"
echo "  ║                                              ║"
echo "  ║   Setelah login, jalanin:                    ║"
echo "  ║   ~/apply-widgets.sh                         ║"
echo "  ║                                              ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
