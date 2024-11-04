-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-----------------------------------------------------------------
-- I defined those below

config.font_size = 16
config.font = wezterm.font("FiraCode Nerd Font Ret", { weight = "Regular" })

-- Theming
-- config.color_scheme = "AdventureTime"
config.color_scheme = "UnderTheSea"

-- Maximised view since by default the window is small
config.initial_rows = 35
config.initial_cols = 135

-- resizing the font makes the widow small or bigger annoying!!
config.window_decorations = "RESIZE"

-- remove the annoying tab bar at the top
config.enable_tab_bar = false

-------------------------------------------------------------------

return config
