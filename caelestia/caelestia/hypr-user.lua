-- User overrides — loaded at the end of hyprland.lua
-- Anything here wins over the default config.

-- (Launcher fix is patched in keybinds.lua — replaced global shortcut with IPC exec)

-- Toggle Performance/Quality Mode
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("toggle-perf"))
