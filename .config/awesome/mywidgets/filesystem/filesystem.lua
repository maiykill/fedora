local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local themecolors = {
	bg = "#232136",
	fg = "#e0def4",
	fs_used = "#9ccfd8",
}
local themefonts = {
	text = "Iosevka Term Extended Bold 14",
}
local icon_fs = ""

-- Capsule styled percentage
local fs_text = wibox.widget.textbox()
fs_text.font = themefonts.text
fs_text.halign = "center"
fs_text.valign = "center"

local fs_capsule = wibox.widget({
	{
		fs_text,
		left = 7,
		right = 2,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0 or themecolors.bg,
	fg = beautiful.cat_lavender,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
	forced_width = 55, -- Only percentage + icon, adjust as you prefer
})

-- Efficiently extract the use% using df
local function get_fs_percent_usage(mountpoint)
	local f = io.popen("df -h " .. mountpoint .. " | tail -1")
	if not f then
		return nil
	end
	local output = f:read("*all") or ""
	f:close()
	local percent = output:match("%s(%d+)%%") -- matches the number before the % sign
	return percent
end

local function update_fs_usage()
	local percent = get_fs_percent_usage("/")
	if percent then
		fs_text.text = percent .. icon_fs
	else
		fs_text.text = "--% " .. icon_fs
	end
end

gears.timer({
	timeout = 8,
	autostart = true,
	call_now = true,
	callback = update_fs_usage,
})

return fs_capsule
