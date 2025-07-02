-------------------------------------------------
-- CPU Widget for Awesome Window Manager
-- Shows the current CPU utilization, temperature, and fan speed (horizontal, Fira Sans 13 for wibar only)
-------------------------------------------------

local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local CMD =
	[[sh -c "grep '^cpu.' /proc/stat; ps -eo 'pid:10,pcpu:5,pmem:5,comm:30,cmd' --sort=-pcpu | grep -v [p]s | grep -v [g]rep | head -11 | tail -n +2"]]
local CMD_slim = [[grep --max-count=1 '^cpu.' /proc/stat]]
local CMD_SENSORS = "sensors"

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/awesome/awesome-wm-widgets/cpu-widget"

-- *** FONT FOR WIBAR ***
local widget_font = "Fira Sans Bold 14"

local cpu_widget = {}
local cpu_rows = { spacing = 4, layout = wibox.layout.fixed.vertical }
local is_update = true
local process_rows = { layout = wibox.layout.fixed.vertical }

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end
local function starts_with(str, start)
	return str:sub(1, #start) == start
end

local function create_textbox(args)
	return wibox.widget({
		text = args.text,
		align = args.align or "left",
		markup = args.markup,
		forced_width = args.forced_width or 40,
		widget = wibox.widget.textbox,
	})
end

local function create_process_header(params)
	local res = wibox.widget({
		create_textbox({ markup = "<b>PID</b>" }),
		create_textbox({ markup = "<b>Name</b>" }),
		{
			create_textbox({ markup = "<b>%CPU</b>" }),
			create_textbox({ markup = "<b>%MEM</b>" }),
			params.with_action_column and create_textbox({ forced_width = 20 }) or nil,
			layout = wibox.layout.align.horizontal,
		},
		layout = wibox.layout.ratio.horizontal,
	})
	res:ajust_ratio(2, 0.2, 0.47, 0.33)
	return res
end

local function create_kill_process_button()
	return wibox.widget({
		{
			id = "icon",
			image = WIDGET_DIR .. "/window-close-symbolic.svg",
			resize = false,
			opacity = 0.1,
			widget = wibox.widget.imagebox,
		},
		widget = wibox.container.background,
	})
end

-- *** Wibar widgets ***
local temp_text = wibox.widget({
	text = "N/A°C",
	font = widget_font,
	widget = wibox.widget.textbox,
	align = "center",
})
local fan_text = wibox.widget({
	text = "N/ARPM",
	font = widget_font,
	widget = wibox.widget.textbox,
	align = "center",
})

local function color_for_temp(temp)
	temp = tonumber(temp)
	if not temp then
		return "#cccccc"
	end
	if temp < 45 then
		return "#268bd2" -- blue
	elseif temp < 60 then
		return "#859900" -- green
	elseif temp < 75 then
		return "#b58900" -- yellow/orange
	else
		return "#dc322f" -- red
	end
end

local function update_temp_and_fan()
	awful.spawn.easy_async_with_shell(CMD_SENSORS, function(stdout)
		-- Get first core temp (or any temp if not found)
		local temp_val
		for core, temp in stdout:gmatch("(Core %d+):%s*[%+]?([%d%.]+)°C") do
			temp_val = temp
			break
		end
		if not temp_val then
			for label, temp in stdout:gmatch("(%w+ temp):%s*[%+]?([%d%.]+)°C") do
				temp_val = temp
				break
			end
		end
		if temp_val then
			local temp_int = tostring(math.floor(tonumber(temp_val) or 0))
			temp_text.markup = string.format(
				"<span font='%s' foreground='%s'>%s°C</span>",
				widget_font,
				color_for_temp(temp_int),
				temp_int
			)
		else
			temp_text.markup = string.format("<span font='%s' foreground='#cccccc'>N/A°C</span>", widget_font)
		end

		-- Get first fan speed
		local fan_val
		for label, speed in stdout:gmatch("(%w+ fan)%s*:%s*([%d]+) RPM") do
			fan_val = speed
			break
		end
		if not fan_val then
			for label, speed in stdout:gmatch("(fan%d+):%s*([%d]+) RPM") do
				fan_val = speed
				break
			end
		end
		if fan_val then
			-- No spaces between fan speed and RPM
			fan_text.markup = string.format("<span font='%s'>%s RPM</span>", widget_font, fan_val)
		else
			fan_text.markup = string.format("<span font='%s'>N/A RPM</span>", widget_font)
		end
	end)
end

local function worker(user_args)
	local args = user_args or {}

	local width = args.width or 50
	local step_width = args.step_width or 2
	local step_spacing = args.step_spacing or 1
	local color = args.color or beautiful.fg_normal
	local background_color = args.background_color or "#00000000"
	local enable_kill_button = args.enable_kill_button or false
	local process_info_max_length = args.process_info_max_length or -1
	local timeout = args.timeout or 1

	local cpugraph_widget = wibox.widget({
		max_value = 100,
		background_color = background_color,
		forced_width = width,
		step_width = step_width,
		step_spacing = step_spacing,
		widget = wibox.widget.graph,
		color = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. color,
	})

	local popup_timer = gears.timer({ timeout = timeout })
	local sensors_timer = gears.timer({
		timeout = 1, -- updated to 1 second interval
		autostart = true,
		call_now = true,
		callback = update_temp_and_fan,
	})

	local popup = awful.popup({
		ontop = true,
		visible = false,
		shape = gears.shape.rounded_rect,
		border_width = 1,
		border_color = beautiful.bg_normal,
		maximum_width = 500,
		offset = { y = 5 },
		widget = {},
	})

	popup:connect_signal("mouse::enter", function()
		is_update = false
	end)
	popup:connect_signal("mouse::leave", function()
		is_update = true
	end)

	cpugraph_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
		if popup.visible then
			popup.visible = not popup.visible
			popup_timer:stop()
		else
			popup:move_next_to(mouse.current_widget_geometry)
			popup_timer:start()
			popup_timer:emit_signal("timeout")
		end
	end)))

	-- Horizontal layout: icon, temp, fan, graph
	cpu_widget = wibox.widget({
		{
			markup = "<span foreground='#2de6e2'>  </span>", -- icon with Dracula purple color
			font = widget_font,
			widget = wibox.widget.textbox,
		},
		temp_text,
		fan_text,
		{
			cpugraph_widget,
			reflection = { horizontal = true },
			layout = wibox.container.mirror,
		},
		layout = wibox.layout.fixed.horizontal,
		spacing = 6,
	})

	-- Update graph in wibar
	local maincpu = {}
	watch(CMD_slim, timeout, function(widget, stdout)
		local _, user, nice, system, idle, iowait, irq, softirq, steal, _, _ =
			stdout:match("(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)")
		local total = user + nice + system + idle + iowait + irq + softirq + steal
		local diff_idle = idle - tonumber(maincpu["idle_prev"] == nil and 0 or maincpu["idle_prev"])
		local diff_total = total - tonumber(maincpu["total_prev"] == nil and 0 or maincpu["total_prev"])
		local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
		maincpu["total_prev"] = total
		maincpu["idle_prev"] = idle
		widget:add_value(diff_usage)
	end, cpugraph_widget)

	-- Update popup
	local cpus = {}
	popup_timer:connect_signal("timeout", function()
		awful.spawn.easy_async(CMD, function(stdout, _, _, _)
			local i = 1
			local j = 1
			for line in stdout:gmatch("[^\r\n]+") do
				if starts_with(line, "cpu") then
					if cpus[i] == nil then
						cpus[i] = {}
					end
					local name, user, nice, system, idle, iowait, irq, softirq, steal, _, _ =
						line:match("(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)")
					local total = user + nice + system + idle + iowait + irq + softirq + steal
					local diff_idle = idle - tonumber(cpus[i]["idle_prev"] == nil and 0 or cpus[i]["idle_prev"])
					local diff_total = total - tonumber(cpus[i]["total_prev"] == nil and 0 or cpus[i]["total_prev"])
					local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
					cpus[i]["total_prev"] = total
					cpus[i]["idle_prev"] = idle
					local row = wibox.widget({
						create_textbox({ text = name }),
						create_textbox({ text = math.floor(diff_usage) .. "%" }),
						{
							max_value = 100,
							value = diff_usage,
							forced_height = 40,
							forced_width = 150,
							paddings = 1,
							margins = 4,
							border_width = 1,
							border_color = beautiful.bg_focus,
							background_color = beautiful.bg_normal,
							bar_border_width = 1,
							bar_border_color = beautiful.bg_focus,
							color = "linear:150,0:0,0:0,#D08770:0.3,#BF616A:0.6," .. beautiful.fg_normal,
							widget = wibox.widget.progressbar,
						},
						layout = wibox.layout.ratio.horizontal,
					})
					row:ajust_ratio(2, 0.15, 0.15, 0.7)
					cpu_rows[i] = row
					i = i + 1
				else
					if is_update == true then
						local pid = trim(string.sub(line, 1, 10))
						local cpu = trim(string.sub(line, 12, 16))
						local mem = trim(string.sub(line, 18, 22))
						local comm = trim(string.sub(line, 24, 53))
						local cmd = trim(string.sub(line, 54))
						local kill_proccess_button = enable_kill_button and create_kill_process_button() or nil
						local pid_name_rest = wibox.widget({
							create_textbox({ text = pid }),
							create_textbox({ text = comm }),
							{
								create_textbox({ text = cpu, align = "center" }),
								create_textbox({ text = mem, align = "center" }),
								kill_proccess_button,
								layout = wibox.layout.fixed.horizontal,
							},
							layout = wibox.layout.ratio.horizontal,
						})
						pid_name_rest:ajust_ratio(2, 0.2, 0.47, 0.33)
						local row = wibox.widget({
							{
								pid_name_rest,
								top = 4,
								bottom = 4,
								widget = wibox.container.margin,
							},
							widget = wibox.container.background,
						})
						row:connect_signal("mouse::enter", function(c)
							c:set_bg(beautiful.bg_focus)
						end)
						row:connect_signal("mouse::leave", function(c)
							c:set_bg(beautiful.bg_normal)
						end)
						if enable_kill_button then
							row:connect_signal("mouse::enter", function()
								kill_proccess_button.icon.opacity = 1
							end)
							row:connect_signal("mouse::leave", function()
								kill_proccess_button.icon.opacity = 0.1
							end)
							kill_proccess_button:buttons(awful.util.table.join(awful.button({}, 1, function()
								row:set_bg("#ff0000")
								awful.spawn.with_shell("kill -9 " .. pid)
							end)))
						end
						awful.tooltip({
							objects = { row },
							mode = "outside",
							preferred_positions = { "bottom" },
							timer_function = function()
								local text = cmd
								if process_info_max_length > 0 and text:len() > process_info_max_length then
									text = text:sub(0, process_info_max_length - 3) .. "..."
								end
								return text:gsub("%s%-", "\n\t-"):gsub(":/", "\n\t\t:/")
							end,
						})
						process_rows[j] = row
						j = j + 1
					end
				end
			end
			popup:setup({
				{
					cpu_rows,
					{
						orientation = "horizontal",
						forced_height = 15,
						color = beautiful.bg_focus,
						widget = wibox.widget.separator,
					},
					create_process_header({ with_action_column = enable_kill_button }),
					process_rows,
					layout = wibox.layout.fixed.vertical,
				},
				margins = 8,
				widget = wibox.container.margin,
			})
		end)
	end)

	-- Initial update
	update_temp_and_fan()

	return cpu_widget
end

return setmetatable(cpu_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
