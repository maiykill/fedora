local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")

-- Theme colors table
local themecolors = {
	icon_fg = "#2de6e2",
	download_fg = "#9ccfd8",
	upload_fg = "#eb6f92",
}

-- Theme fonts table
local themefonts = {
	icon_font = "FiraCode Nerd Font Propo Bold 13",
	number_font = "FiraCode Nerd Font Propo Bold 13",
}

-- Icon to display on the left
local icon_char = ""

-- Find or create a session-specific directory in /tmp for awesome
local TMP_SESSION_FILE = "/tmp/.awesome-instance-path"
local DATA_DIR

local session_dir_file = io.open(TMP_SESSION_FILE, "r")
if session_dir_file then
	DATA_DIR = session_dir_file:read("*l")
	session_dir_file:close()
else
	local handle = io.popen("mktemp -d /tmp/awesome-XXXXXXXX")
	DATA_DIR = handle:read("*l")
	handle:close()
	local write_file = io.open(TMP_SESSION_FILE, "w")
	if write_file then
		write_file:write(DATA_DIR .. "\n")
		write_file:close()
	end
end

local NETSPEED_DIR = DATA_DIR .. "/mywidgets/net"
awful.spawn.with_shell("mkdir -p " .. NETSPEED_DIR)
local DATA_FILE = NETSPEED_DIR .. "/net_totals.lua"

local net_speed_widget = {}

local function convert_to_h(bytes)
	local speed, dim
	if bytes < 1024 then
		speed, dim = bytes, "B"
	elseif bytes < 1024 ^ 2 then
		speed, dim = bytes / 1024, "K"
	elseif bytes < 1024 ^ 3 then
		speed, dim = bytes / (1024 ^ 2), "M"
	elseif bytes < 1024 ^ 4 then
		speed, dim = bytes / (1024 ^ 3), "G"
	else
		speed, dim = bytes / (1024 ^ 4), "T"
	end
	return string.format("%.1f%s", speed, dim)
end

local function format_total_bytes(bytes)
	local speed, dim
	if bytes < 1024 then
		speed, dim = bytes, "B"
	elseif bytes < 1024 ^ 2 then
		speed, dim = bytes / 1024, "KB"
	elseif bytes < 1024 ^ 3 then
		speed, dim = bytes / (1024 ^ 2), "MB"
	elseif bytes < 1024 ^ 4 then
		speed, dim = bytes / (1024 ^ 3), "GB"
	else
		speed, dim = bytes / (1024 ^ 4), "TB"
	end
	return string.format("%.3f %s", speed, dim)
end

-- Save totals persistently
local function save_totals(total)
	local file = io.open(DATA_FILE, "w")
	if file then
		file:write("return {\n")
		for iface, data in pairs(total) do
			file:write(string.format('  ["%s"] = { rx = %d, tx = %d },\n', iface, data.rx or 0, data.tx or 0))
		end
		file:write("}\n")
		file:close()
	end
end

-- Load totals from file
local function load_totals()
	local file = io.open(DATA_FILE, "r")
	if file then
		file:close()
		local chunk = loadfile(DATA_FILE)
		if chunk then
			local success, data = pcall(chunk)
			if success and type(data) == "table" then
				return data
			end
		end
	end
	return {}
end

local function worker(user_args)
	local args = user_args or {}
	local timeout = args.timeout or 1
	local total_width = args.width or 110

	-- Minimal forced width for the speeds combined
	-- We'll distribute total_width minus icon width amongst the speed textboxes
	local icon_width = 30
	local spacing_between_speeds = 0 -- pixels between download and upload speeds text
	local speeds_width = total_width - icon_width - spacing_between_speeds

	-- Split speeds_width approximately evenly for download and upload speeds texts
	local speed_width_each = math.floor(speeds_width / 2)

	-- Create icon widget (single icon on the left)
	local icon_widget = wibox.widget({
		markup = string.format(
			'<span font="%s" foreground="%s">%s</span>',
			themefonts.icon_font,
			themecolors.icon_fg,
			icon_char
		),
		align = "center",
		valign = "center",
		forced_width = icon_width,
		widget = wibox.widget.textbox,
	})

	-- Download speed textbox
	local download_text = wibox.widget({
		id = "rx_speed",
		forced_width = speed_width_each,
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Upload speed textbox
	local upload_text = wibox.widget({
		id = "tx_speed",
		forced_width = speed_width_each,
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Container for both speeds side by side with a small spacing
	local speeds_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = spacing_between_speeds,
		download_text,
		upload_text,
	})

	-- Main net_speed widget: icon on left and speeds next to it
	net_speed_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = 0,
		icon_widget,
		speeds_widget,
	})

	-- Set fonts for speed textboxes
	download_text.font = themefonts.number_font
	upload_text.font = themefonts.number_font

	local prev = {}
	local total = load_totals()
	local save_counter = 0

	local function get_bytes_direct()
		local rx, tx = {}, {}
		local ifaces = {}
		local handle = io.popen("ls /sys/class/net 2>/dev/null")
		if handle then
			for iface in handle:lines() do
				if
					iface ~= "lo"
					and not iface:match("^docker")
					and not iface:match("^veth")
					and not iface:match("^virbr")
					and not iface:match("^br%-")
					and not iface:match("^vmnet")
					and not iface:match("^vboxnet")
					and not iface:match("^tun")
					and not iface:match("^tap")
				then
					table.insert(ifaces, iface)
				end
			end
			handle:close()
		end

		for _, iface in ipairs(ifaces) do
			local rx_file = io.open("/sys/class/net/" .. iface .. "/statistics/rx_bytes")
			local tx_file = io.open("/sys/class/net/" .. iface .. "/statistics/tx_bytes")
			if rx_file and tx_file then
				rx[iface] = tonumber(rx_file:read("*a")) or 0
				tx[iface] = tonumber(tx_file:read("*a")) or 0
				rx_file:close()
				tx_file:close()
			end
		end
		return rx, tx, ifaces
	end

	awful.tooltip({
		objects = { net_speed_widget },
		mode = "mouse",
		timer_function = function()
			local text = ""
			local grand_rx, grand_tx = 0, 0
			local ifaces = {}
			for iface, _ in pairs(total) do
				table.insert(ifaces, iface)
			end
			table.sort(ifaces)
			for i, iface in ipairs(ifaces) do
				local rx = total[iface] and total[iface].rx or 0
				local tx = total[iface] and total[iface].tx or 0
				text = text .. string.format("Interface %d (%s):\n", i, iface)
				text = text .. string.format("  ↓ %s downloaded\n", format_total_bytes(rx))
				text = text .. string.format("  ↑ %s uploaded\n", format_total_bytes(tx))
				grand_rx = grand_rx + rx
				grand_tx = grand_tx + tx
				text = text .. "\n"
			end
			text = text
				.. string.format(
					"Total (all interfaces):\n  ↓ %s downloaded\n  ↑ %s uploaded",
					format_total_bytes(grand_rx),
					format_total_bytes(grand_tx)
				)
			return text
		end,
	})

	local function update_widget()
		local rx, tx, ifaces = get_bytes_direct()
		local total_rx, total_tx = 0, 0

		for _, iface in ipairs(ifaces) do
			if not prev[iface] then
				prev[iface] = { rx = rx[iface], tx = tx[iface] }
				total[iface] = total[iface] or { rx = 0, tx = 0 }
			end
			local delta_rx = rx[iface] - (prev[iface].rx or 0)
			local delta_tx = tx[iface] - (prev[iface].tx or 0)
			if delta_rx < 0 then
				delta_rx = 0
			end
			if delta_tx < 0 then
				delta_tx = 0
			end
			total[iface].rx = (total[iface].rx or 0) + delta_rx
			total[iface].tx = (total[iface].tx or 0) + delta_tx
			prev[iface].rx = rx[iface]
			prev[iface].tx = tx[iface]
			total_rx = total_rx + delta_rx
			total_tx = total_tx + delta_tx
		end

		download_text:set_markup(
			string.format('<span foreground="%s">%s</span>', themecolors.download_fg, convert_to_h(total_rx / timeout))
		)
		upload_text:set_markup(
			string.format('<span foreground="%s">%s</span>', themecolors.upload_fg, convert_to_h(total_tx / timeout))
		)

		save_counter = save_counter + 1
		if save_counter >= 10 then
			save_totals(total)
			save_counter = 0
		end
	end

	local timer = gears.timer({
		timeout = timeout,
		autostart = true,
		call_now = true,
		callback = update_widget,
	})

	net_speed_widget._timer = timer
	net_speed_widget:connect_signal("destroyed", function()
		save_totals(total)
	end)

	return net_speed_widget
end

return setmetatable(net_speed_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
