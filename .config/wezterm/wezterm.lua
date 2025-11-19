-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-----------------------------------------------------------------
-- I defined those below
-----------------------------------------------------------------

---- Font ----
-- config.font_size = 17 -- while using xfce
config.font_size = 15.25 -- while using awesome
-- config.font = wezterm.font("FiraCode Nerd Font Ret", { weight = "Regular" })
config.font = wezterm.font("CodeNewRoman Nerd Font", { weight = "Regular" })

---- Cursor ----
config.colors = { cursor_fg = "#ff0000", cursor_bg = "#00ff00" }
config.default_cursor_style = "SteadyBar"

---- Color Scheme ----
-- config.color_scheme = 'VisiBone (terminal.sexy)'
-- config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'tokyonight_night'
-- config.color_scheme = 'Rosé Pine (Gogh)'
-- config.color_scheme = 'Poimandres'
-- config.color_scheme = 'Popping and Locking'
-- config.color_scheme = 'Purpledream (base16)'
-- config.color_scheme = 'Obsidian (Gogh)'
-- config.color_scheme = 'Ocean Dark (Gogh)'
-- config.color_scheme = 'Oceanic Next (Gogh)'
-- config.color_scheme = 'OceanicMaterial'
-- config.color_scheme = 'Nancy (terminal.sexy)'
-- config.color_scheme = 'Nature Suede (terminal.sexy)'
config.color_scheme = "Night Owl (Gogh)"
-- config.color_scheme = 'Nord (Gogh)'
-- config.color_scheme = 'NvimDark'
-- config.color_scheme = 'Mashup Colors (terminal.sexy)'
-- config.color_scheme = 'MaterialDesignColors'
-- config.color_scheme = 'MaterialOcean'
-- config.color_scheme = 'Mellifluous'
-- config.color_scheme = 'Mikado (terminal.sexy)'
-- config.color_scheme = 'Mikazuki (terminal.sexy)'
-- config.color_scheme = 'Molokai (Gogh)'
-- config.color_scheme = 'Mona Lisa (Gogh)'
-- config.color_scheme = 'Moonfly (Gogh)'
-- config.color_scheme = 'Laserwave (Gogh)'
-- config.color_scheme = 'Londontube (dark) (terminal.sexy)'
-- config.color_scheme = 'lovelace'
-- config.color_scheme = 'Kanagawa (Gogh)'
-- config.color_scheme = 'Glacier'
-- config.color_scheme = 'GruvboxDarkHard'
-- config.color_scheme = "Github Dark (Gogh)"
-- config.color_scheme = 'flexoki-dark'
-- config.color_scheme = 'ForestBlue'
-- config.color_scheme = 'Ef-Cherie'
-- config.color_scheme = 'Catppuccin Mocha'

-- Fps --
config.max_fps = 120

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

-----------------------------------------------------------------
-- Keybindings
-----------------------------------------------------------------
config.keys = {
	{
		key = "Enter",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewWindow({
			-- No cwd specified here means it inherits from current pane
			args = {}, -- or omit entirely
		}),
	},
}

-----------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

return config
