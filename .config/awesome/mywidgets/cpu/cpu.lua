local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Theme colors (customize as needed)
local themecolors = {
	bg = "#232136",
	fg = "#e0def4",
	temp = "#f6cba8",
	fan = "#74c7ec",
	cpu = "#f4b8e4",
}

-- Fonts
local themefonts = {
	icon = "Iosevka Term Extended Bold 14",
	text = "Iosevka Term Extended Bold 14",
}

-- Icons (Nerd Fonts/Unicode)
local icons = {
	temp = "", -- No icon before temp.
	fan = " ",
	cpu = " ",
}

-- Textboxes for each metric
local temp_tb = wibox.widget({
	text = "--°C",
	font = themefonts.text,
	-- align = "center",
	-- valign = "center",
	widget = wibox.widget.textbox,
})
local temp_box = wibox.widget({
	temp_tb,
	fg = themecolors.temp,
	widget = wibox.container.background,
})

local fan_tb = wibox.widget({
	text = "--" .. icons.fan,
	font = themefonts.text,
	-- align = "center",
	-- valign = "center",
	widget = wibox.widget.textbox,
})
local fan_box = wibox.widget({
	fan_tb,
	fg = themecolors.fan,
	widget = wibox.container.background,
})

local cpu_tb = wibox.widget({
	text = "--" .. icons.cpu,
	font = themefonts.text,
	-- align = "center",
	-- valign = "center",
	widget = wibox.widget.textbox,
})
local cpu_box = wibox.widget({
	cpu_tb,
	fg = themecolors.cpu,
	widget = wibox.container.background,
})

local content_row = wibox.widget({
	temp_box,
	fan_box,
	cpu_box,
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})

local cpu_widget = wibox.widget({
  {
	content_row,
		left = 6,
		right = 6,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
})

-- Helper: read first line of file, return as number or nil
local function read_file_num(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local value = f:read("*l")
	f:close()
	return tonumber(value)
end

-- Helper: parse /proc/stat line and calculate CPU usage percent
local prev_total, prev_idle = nil, nil
local function get_cpu_usage()
	local f = io.open("/proc/stat", "r")
	if not f then
		return nil
	end
	local l = f:read("*l")
	f:close()
	if not l then
		return nil
	end
	local user, nice, system, idle, iowait, irq, softirq, steal =
		l:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
	user, nice, system, idle, iowait, irq, softirq, steal =
		tonumber(user),
		tonumber(nice),
		tonumber(system),
		tonumber(idle),
		tonumber(iowait),
		tonumber(irq),
		tonumber(softirq),
		tonumber(steal)
	if not user then
		return nil
	end
	local idle_all = idle + iowait
	local non_idle = user + nice + system + irq + softirq + steal
	local total = idle_all + non_idle
	-- On first run, just store and return nil
	if (not prev_total) or not prev_idle then
		prev_total = total
		prev_idle = idle_all
		return nil
	end
	local diff_total = total - prev_total
	local diff_idle = idle_all - prev_idle
	prev_total = total
	prev_idle = idle_all
	if diff_total == 0 then
		return 0
	end
	local cpu_pct = (diff_total - diff_idle) / diff_total * 100
	return math.floor(cpu_pct + 0.5)
end

-- Periodic update function
local function update_widget()
	-- Temp (in millidegrees)
	local temp_raw = read_file_num("/sys/class/hwmon/hwmon7/temp1_input")
	local temp_c = temp_raw and math.floor(temp_raw / 1000 + 0.5) or "--"
	temp_tb.text = string.format("%s°C", temp_c)

	-- Fan
	local fan = read_file_num("/sys/class/hwmon/hwmon7/fan1_input")
	fan_tb.text = string.format("%s%s", fan or "--", icons.fan)

	-- CPU percentage (requires at least 2 reads, shows "--" on very first update)
	local cpu_pct = get_cpu_usage()
	cpu_tb.text = string.format("%s%s", cpu_pct and tostring(cpu_pct) or "--", icons.cpu)
end

gears.timer({
	timeout = 2,
	autostart = true,
	call_now = true,
	callback = update_widget,
})

return cpu_widget
