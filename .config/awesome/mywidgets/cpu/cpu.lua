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

-- ----- Helper: Find hwmonX path for named sensor -----
local function find_hwmon_path(sensor_name, sensor_file)
	for i = 0, 20 do
		local base = "/sys/class/hwmon/hwmon" .. i
		local fname = base .. "/name"
		local f = io.open(fname, "r")
		if f then
			local name = f:read("*l")
			f:close()
			if name == sensor_name then
				local candidate = base .. "/" .. sensor_file
				local f2 = io.open(candidate)
				if f2 then
					f2:close()
					return candidate
				end
			end
		end
	end
	return nil
end

-- ----- Helper: Read number from file (once) -----
local function read_file_num(path)
	if not path then
		return nil
	end
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local value = f:read("*l")
	f:close()
	return tonumber(value)
end

-- ----- CPU Usage calculation (pure Lua, minimal memory) -----
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

-- ----- Sensor path discovery (once per boot, per widget lifetime) -----
local temp_path, fan_path = nil, nil
local function discover_paths()
	temp_path = find_hwmon_path("thinkpad", "temp1_input")
	fan_path = find_hwmon_path("thinkpad", "fan1_input")
end
discover_paths()

-- Minimal periodic update
local function update_widget()
	-- -- Sensor paths may change after suspend/resume, so rediscover if missing
	-- if not temp_path then
	-- 	temp_path = find_hwmon_path("thinkpad", "temp1_input")
	-- end
	-- if not fan_path then
	-- 	fan_path = find_hwmon_path("thinkpad", "fan1_input")
	-- end

	-- Temperature (in millidegree C)
	local temp_raw = read_file_num(temp_path)
	local temp_c = temp_raw and math.floor(temp_raw / 1000 + 0.5) or "--"
	temp_tb.text = string.format("%s°C", temp_c)

	-- Fan (RPM)
	local fan = read_file_num(fan_path)
	fan_tb.text = string.format("%s%s", fan or "--", icons.fan)

	-- CPU percentage (as before)
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
