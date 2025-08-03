local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

-- Theme colors table (including all your original colors)
local themecolors = {
	-- Rosé Pine
	rose_love = "#eb6f92",
	rose_gold = "#f6c177",
	rose_foam = "#9ccfd8",
	rose_iris = "#c4a7e7",
	rose_pine = "#31748f",
	-- Catppuccin
	cat_lavender = "#b4befe",
	cat_peach = "#fab387",
	cat_mauve = "#cba6f7",
	cat_green = "#a6e3a1",
	cat_red = "#f38ba8",
	-- One Dark
	one_blue = "#61afef",
	one_yellow = "#e5c07b",
	one_red = "#e06c75",
	one_green = "#98c379",
	one_fg = "#abb2bf",
	-- Zenburn
	zen_yellow = "#f0dfaf",
	zen_orange = "#dfaf8f",
	zen_green = "#afd787",
	zen_red = "#dca3a3",
	zen_bg = "#3f3f3f",
}

-- Theme fonts table
local themefonts = {
	main = "FiraCode Nerd Font Propo Bold 13",
}

-- Theme icons table
local themeicons = {
	battery = "🔋",
	charging = "🔌",
	full = "⚡",
}

-- Battery widget textbox
local battery_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = themefonts.main,
})

-- Stepwise color selector by capacity %
local function get_color_by_capacity(capacity)
	if capacity <= 10 then
		return themecolors.one_red
	elseif capacity <= 20 then
		return themecolors.rose_love
	elseif capacity <= 35 then
		return themecolors.cat_peach
	elseif capacity <= 50 then
		return themecolors.zen_red
	elseif capacity <= 65 then
		return themecolors.zen_orange
	elseif capacity <= 80 then
		return themecolors.cat_green
	elseif capacity <= 90 then
		return themecolors.rose_foam
	elseif capacity <= 98 then
		return themecolors.one_blue
	else
		return themecolors.cat_lavender
	end
end

-- Update battery widget markup based on current status and capacity
local function update_battery()
	local bat_path = "/sys/class/power_supply/BAT0/"
	local f_capacity = io.open(bat_path .. "capacity", "r")
	local f_status = io.open(bat_path .. "status", "r")

	if not f_capacity or not f_status then
		battery_widget:set_markup(
			string.format('<span foreground="%s">%s N/A</span>', themecolors.one_red, themeicons.battery)
		)
		return
	end

	local capacity = tonumber(f_capacity:read("*all"))
	local status = f_status:read("*all"):gsub("\n", "")

	f_capacity:close()
	f_status:close()

	local icon, color

	if status == "Charging" then
		icon = themeicons.charging
		color = get_color_by_capacity(capacity)
	elseif status == "Discharging" then
		icon = themeicons.battery
		color = get_color_by_capacity(capacity)
	else
		-- Full, Unknown, or other statuses
		icon = themeicons.full
		color = themecolors.rose_gold
	end

	battery_widget:set_markup(string.format('<span foreground="%s">%s%d%%</span>', color, icon, capacity))
end

-- Initial update
update_battery()

-- Timer to update the widget every second (or change as needed)
gears.timer({
	timeout = 1,
	autostart = true,
	call_now = true,
	callback = update_battery,
})

-- Tooltip showing status
awful.tooltip({
	objects = { battery_widget },
	timer_function = function()
		local f_status = io.open("/sys/class/power_supply/BAT0/status", "r")
		local status = f_status and f_status:read("*all"):gsub("\n", "") or "N/A"
		if f_status then
			f_status:close()
		end
		return "Status: " .. status
	end,
	font = themefonts.main,
	bg = "#757b90", -- Cement-like background
	fg = "#ffffff",
})

return battery_widget
