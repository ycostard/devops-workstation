local wezterm = require("wezterm")

-- Chargement des modules
local config = wezterm.config_builder()

-- ─── Apparence ───────────────────────────────────────────────
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13.0

-- ─── Barre d'onglets ──────────────────────────────────────────
config.hide_tab_bar_if_only_one_tab = true

-- Transparence et blur (macOS uniquement pour le blur)
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20

return config