-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-----------------------------------------------------------------

-- I defined those below
config.font_size = 16
config.font = wezterm.font("FiraCode Nerd Font Ret", { weight = "Regular" })

-- For example, changing the color scheme:
config.color_scheme = "AdventureTime"

-- Maximised view since by default the window is small
config.initial_rows = 34
config.initial_cols = 136
config.window_decorations = "NONE"

-------------------------------------------------------------------

return config
