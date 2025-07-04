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

---- Color Scheme ----
-- config.color_scheme = 'Vag (Gogh)'
config.color_scheme = "Vesper"
-- config.color_scheme = "Vice Dark (base16)"
-- config.color_scheme = "VisiBlue (terminal.sexy)"

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
