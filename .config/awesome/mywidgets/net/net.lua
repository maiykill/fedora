local watch = require("awful.widget.watch")
local wibox = require("wibox")
local awful = require("awful")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/awesome/mywidgets/net/"
local ICONS_DIR = WIDGET_DIR .. "icons/"

local net_speed_widget = {}

local function convert_to_h(bytes)
	local speed
	local dim
	if bytes < 1024 then
		speed = bytes
		dim = "B"
	elseif bytes < 1024 * 1024 then
		speed = bytes / 1024
		dim = "k"
	elseif bytes < 1024 * 1024 * 1024 then
		speed = bytes / (1024 * 1024)
		dim = "M"
	elseif bytes < 1024 * 1024 * 1024 * 1024 then
		speed = bytes / (1024 * 1024 * 1024)
		dim = "G"
	else
		speed = tonumber(bytes)
		dim = "b/s"
	end
	return string.format("%.1f %s", speed, dim)
end

-- total bytes now formatted with 3 decimal points
local function format_total_bytes(bytes)
	local speed
	local dim
	if bytes < 1024 then
		speed = bytes
		dim = "B"
	elseif bytes < 1024 * 1024 then
		speed = bytes / 1024
		dim = "kB"
	elseif bytes < 1024 * 1024 * 1024 then
		speed = bytes / (1024 * 1024)
		dim = "MB"
	elseif bytes < 1024 * 1024 * 1024 * 1024 then
		speed = bytes / (1024 * 1024 * 1024)
		dim = "GB"
	else
		speed = bytes / (1024 * 1024 * 1024 * 1024)
		dim = "TB"
	end
	return string.format("%.3f %s", speed, dim)
end

local function split(string_to_split, separator)
	if separator == nil then
		separator = "%s"
	end
	local t = {}

	for str in string.gmatch(string_to_split, "([^" .. separator .. "]+)") do
		table.insert(t, str)
	end

	return t
end

local function worker(user_args)
	local args = user_args or {}

	local interface = args.interface or "*"
	local timeout = args.timeout or 1
	local width = args.width or 55

	net_speed_widget = wibox.widget({
		{
			id = "rx_speed",
			forced_width = width,
			align = "right",
			widget = wibox.widget.textbox,
		},
		{
			image = ICONS_DIR .. "down.svg",
			widget = wibox.widget.imagebox,
		},
		{
			image = ICONS_DIR .. "up.svg",
			widget = wibox.widget.imagebox,
		},
		{
			id = "tx_speed",
			forced_width = width,
			align = "left",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.fixed.horizontal,
	})
	net_speed_widget:get_children_by_id("rx_speed")[1].font = "Fira Sans Bold 14"
	net_speed_widget:get_children_by_id("tx_speed")[1].font = "Fira Sans Bold 14"

	-- Initialize total counters
	local total_rx = 0
	local total_tx = 0
	local prev_rx = 0
	local prev_tx = 0

	-- Create tooltip for hover information
	local tooltip = awful.tooltip({
		objects = { net_speed_widget },
		mode = "mouse",
		timer_function = function()
			return "Total transferred since uptime:\n↓ "
				.. format_total_bytes(total_rx)
				.. " downloaded\n↑ "
				.. format_total_bytes(total_tx)
				.. " uploaded"
		end,
	})

	local update_widget = function(widget, stdout)
		local cur_vals = split(stdout, "\r\n")

		local cur_rx = 0
		local cur_tx = 0

		for i, v in ipairs(cur_vals) do
			if i % 2 == 1 then
				cur_rx = cur_rx + v
			end
			if i % 2 == 0 then
				cur_tx = cur_tx + v
			end
		end

		-- Calculate delta from previous measurement
		local delta_rx = (cur_rx - prev_rx)
		local delta_tx = (cur_tx - prev_tx)

		-- Update totals
		total_rx = total_rx + delta_rx
		total_tx = total_tx + delta_tx

		local speed_rx = delta_rx / timeout
		local speed_tx = delta_tx / timeout

		widget
			:get_children_by_id("rx_speed")[1]
			:set_markup('<span foreground="' .. "#9ccfd8" .. '">' .. convert_to_h(speed_rx) .. "</span>")
		widget
			:get_children_by_id("tx_speed")[1]
			:set_markup('<span foreground="' .. "#eb6f92" .. '">' .. convert_to_h(speed_tx) .. "</span>")

		prev_rx = cur_rx
		prev_tx = cur_tx
	end

	watch(
		string.format([[bash -c "cat /sys/class/net/%s/statistics/*_bytes"]], interface),
		timeout,
		update_widget,
		net_speed_widget
	)

	return net_speed_widget
end

return setmetatable(net_speed_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
