local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Theme colors (add all you need)
local themecolors = {
	rose_love = "#eb6f92",
	rose_gold = "#f6c177",
	rose_foam = "#9ccfd8",
	cat_lavender = "#b4befe",
	cat_peach = "#fab387",
	zen_red = "#dca3a3",
	zen_orange = "#dfaf8f",
	cat_green = "#a6e3a1",
	one_blue = "#61afef",
	one_red = "#e06c75",
}

-- Fonts
local themefonts = {
	text = "Iosevka Term Extended Bold 14",
}

-- Icons
local icons = {
	battery = "🔋",
	charging = "🔌",
	full = "⚡",
}

-- Battery value textbox (NO markup)
local battery_textbox = wibox.widget({
	text = "--%",
	font = themefonts.text,
	widget = wibox.widget.textbox,
})

local battery_iconbox = wibox.widget({
	text = icons.battery,
	font = themefonts.text,
	widget = wibox.widget.textbox,
})

local battery_row = wibox.widget({
	battery_iconbox,
	battery_textbox,
	layout = wibox.layout.fixed.horizontal,
	spacing = 2,
})

local battery_widget = wibox.widget({
	{
		battery_row,
		left = 6,
		right = 6,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0,
	-- fg = themecolors.one_red,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
})

-- Stepwise color logic
local function get_color_by_capacity(cap)
	if cap <= 10 then
		return themecolors.one_red
	elseif cap <= 20 then
		return themecolors.rose_love
	elseif cap <= 35 then
		return themecolors.cat_peach
	elseif cap <= 50 then
		return themecolors.zen_red
	elseif cap <= 65 then
		return themecolors.zen_orange
	elseif cap <= 80 then
		return themecolors.cat_green
	elseif cap <= 90 then
		return themecolors.rose_foam
	elseif cap <= 98 then
		return themecolors.one_blue
	else
		return themecolors.cat_lavender
	end
end

-- Actual update logic: only set values and widget fg/icon
local function update_battery()
	local base = "/sys/class/power_supply/BAT0/"
	local fcap = io.open(base .. "capacity", "r")
	local fstat = io.open(base .. "status", "r")

	if not fcap or not fstat then
		battery_textbox.text = "N/A"
		battery_iconbox.text = icons.battery
		battery_widget.fg = themecolors.one_red
		if fcap then
			fcap:close()
		end
		if fstat then
			fstat:close()
		end
		return
	end

	local cap = tonumber(fcap:read("*all"))
	local stat = fstat:read("*all"):gsub("%s+", "")
	fcap:close()
	fstat:close()

	local fgcolor, icon
	fgcolor = get_color_by_capacity(cap)
	if stat == "Charging" then
		icon = icons.charging
	elseif stat == "Discharging" then
		icon = icons.battery
	else
		icon = icons.full
		fgcolor = themecolors.rose_gold
	end

	battery_widget.fg = fgcolor
	battery_iconbox.text = icon
	battery_textbox.text = string.format("%d%%", cap)
end

update_battery()
gears.timer({
	timeout = 6,
	autostart = true,
	call_now = true,
	callback = update_battery,
})

return battery_widget
