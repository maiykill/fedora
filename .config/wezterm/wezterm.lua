-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-----------------------------------------------------------------
-- I defined those below
-----------------------------------------------------------------

---- Font ----
config.font_size = 17
-- config.font = wezterm.font("FiraCode Nerd Font Ret", { weight = "Regular" })
config.font = wezterm.font("CodeNewRoman Nerd Font", { weight = "Regular" })

---- Cursor ----
config.colors = { cursor_fg = "#ff0000", cursor_bg = "#00ff00" }
config.default_cursor_style = 'SteadyBar'

---- Color Scheme ----
-- config.color_scheme = 'VisiBone (terminal.sexy)'
-- config.color_scheme = 'UnderTheSea'
-- config.color_scheme = 'Tangoesque (terminal.sexy)'
config.color_scheme = 'Tomorrow Night (Gogh)'
-- config.color_scheme = 'Red Planet'

---- Maximised view since by default the window is small ----
config.initial_rows = 35
config.initial_cols = 135

---- resizing the font makes the widow small or bigger annoying!! ----
config.window_decorations = "RESIZE"

---- remove the annoying tab bar at the top ----
config.enable_tab_bar = false

---- remove the confirmation wizard asking Yes or No while Closing ----
config.window_close_confirmation = "NeverPrompt"

-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 1000000
-------------------------------------------------------------------
-------------------------------------------------------------------

return config
