local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Theme colors
local themecolors = {
	bg = "#232136",
	fg = "#e0def4",
	ram = "#c690f6",
}

-- Fonts
local themefonts = {
	icon = "Iosevka Term Extended Bold 14",
	text = "Iosevka Term Extended Bold 14",
}

-- Icons
local icons = {
	ram = "󰟜 ",
}

-- RAM textbox
local ram_tb = wibox.widget({
	text = "--G",
	font = themefonts.text,
	widget = wibox.widget.textbox,
})

local ram_box = wibox.widget({
	ram_tb,
	fg = themecolors.ram,
	widget = wibox.container.background,
})

local content_row = wibox.widget({
	ram_box,
	layout = wibox.layout.fixed.horizontal,
})

local ram_widget = wibox.widget({
	{
		content_row,
		left = 7,
		right = 2,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
})

-- Helper: read and parse /proc/meminfo
local function get_ram_usage()
	local f = io.open("/proc/meminfo", "r")
	if not f then
		return nil
	end

	local meminfo = f:read("*a")
	f:close()

	-- Extract values in KB
	local mem_total = meminfo:match("MemTotal:%s*(%d+)%s*kB")
	local mem_available = meminfo:match("MemAvailable:%s*(%d+)%s*kB")

	if not (mem_total and mem_available) then
		return nil
	end

	mem_total = tonumber(mem_total)
	mem_available = tonumber(mem_available)

	-- Calculate used memory (similar to 'free' command)
	local mem_used = mem_total - mem_available

	-- Convert to GB
	local used_gb = mem_used / 1024 / 1024

	return used_gb
end

-- Helper: format GB with proper precision
local function format_gb(gb)
	if gb < 10 then
		return string.format("%.2fG", gb)
	else
		return string.format("%.1fG", gb)
	end
end

-- Update function
local function update_widget()
	local used_gb = get_ram_usage()
	if used_gb then
		ram_tb.text = string.format("%s%s", format_gb(used_gb), icons.ram)
	else
		ram_tb.text = "--G" .. icons.ram
	end
end

gears.timer({
	timeout = 4,
	autostart = true,
	call_now = true,
	callback = update_widget,
})

return ram_widget
