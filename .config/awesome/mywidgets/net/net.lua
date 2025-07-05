local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")

-- Find or create a session-specific directory in /tmp for awesome
local TMP_SESSION_FILE = "/tmp/.awesome-instance-path"
local DATA_DIR

-- Try to read the session path from file
local session_dir_file = io.open(TMP_SESSION_FILE, "r")
if session_dir_file then
    DATA_DIR = session_dir_file:read("*l")
    session_dir_file:close()
else
    -- Create a new session directory in the format /tmp/awesome-XXXXXXXX
    local handle = io.popen("mktemp -d /tmp/awesome-XXXXXXXX")
    DATA_DIR = handle:read("*l")
    handle:close()
    -- Save it for later use in this session
    local write_file = io.open(TMP_SESSION_FILE, "w")
    if write_file then
        write_file:write(DATA_DIR .. "\n")
        write_file:close()
    end
end

local NETSPEED_DIR = DATA_DIR .. "/mywidgets/net"
awful.spawn.with_shell("mkdir -p " .. NETSPEED_DIR)
local DATA_FILE = NETSPEED_DIR .. "/net_totals.lua"

local ICON_FONT = "FiraCode Nerd Font Propo Bold 14"
local NUMBER_FONT = "Fira Sans Bold 14"

local net_speed_widget = {}

local function convert_to_h(bytes)
	local speed, dim
	if bytes < 1024 then
		speed, dim = bytes, "B"
	elseif bytes < 1024 * 1024 then
		speed, dim = bytes / 1024, "K"
	elseif bytes < 1024 * 1024 * 1024 then
		speed, dim = bytes / (1024 * 1024), "M"
	elseif bytes < 1024 * 1024 * 1024 * 1024 then
		speed, dim = bytes / (1024 * 1024 * 1024), "G"
	else
		speed, dim = bytes / (1024 * 1024 * 1024 * 1024), "T"
	end
	return string.format("%.1f %s", speed, dim)
end

local function format_total_bytes(bytes)
	local speed, dim
	if bytes < 1024 then
		speed, dim = bytes, "B"
	elseif bytes < 1024 * 1024 then
		speed, dim = bytes / 1024, "KB"
	elseif bytes < 1024 * 1024 * 1024 then
		speed, dim = bytes / (1024 * 1024), "MB"
	elseif bytes < 1024 * 1024 * 1024 * 1024 then
		speed, dim = bytes / (1024 * 1024 * 1024), "GB"
	else
		speed, dim = bytes / (1024 * 1024 * 1024 * 1024), "TB"
	end
	return string.format("%.3f %s", speed, dim)
end

-- Save totals to file for persistence
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

-- Load totals from file for persistence
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
	local width = args.width or 55

	net_speed_widget = wibox.widget({
		{
			id = "rx_speed",
			forced_width = width,
			align = "right",
			widget = wibox.widget.textbox,
		},
		{
			id = "icon_down",
			markup = '<span font="'..ICON_FONT..'" foreground="#9ccfd8"> ↓ </span>',
			widget = wibox.widget.textbox,
		},
		{
			id = "icon_up",
			markup = '<span font="'..ICON_FONT..'" foreground="#eb6f92">↑</span>',
			widget = wibox.widget.textbox,
		},
		{
			id = "tx_speed",
			forced_width = width,
			align = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.fixed.horizontal,
	})

	net_speed_widget:get_children_by_id("rx_speed")[1].font = NUMBER_FONT
	net_speed_widget:get_children_by_id("tx_speed")[1].font = NUMBER_FONT

	local prev = {}
	local total = load_totals()
	local save_counter = 0

	local function get_bytes_direct()
		local rx, tx = {}, {}
		local ifaces = {}
		local handle = io.popen("ls /sys/class/net 2>/dev/null")
		if handle then
			for iface in handle:lines() do
				if iface ~= "lo"
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
			text = text .. string.format("Total (all interfaces):\n  ↓ %s downloaded\n  ↑ %s uploaded",
				format_total_bytes(grand_rx), format_total_bytes(grand_tx))
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
			if delta_rx < 0 then delta_rx = 0 end
			if delta_tx < 0 then delta_tx = 0 end
			total[iface].rx = (total[iface].rx or 0) + delta_rx
			total[iface].tx = (total[iface].tx or 0) + delta_tx
			prev[iface].rx = rx[iface]
			prev[iface].tx = tx[iface]
			total_rx = total_rx + delta_rx
			total_tx = total_tx + delta_tx
		end

		net_speed_widget:get_children_by_id("rx_speed")[1]:set_markup(
			'<span font="'..NUMBER_FONT..'" foreground="#9ccfd8">' .. convert_to_h(total_rx / timeout) .. "</span>"
		)
		net_speed_widget:get_children_by_id("tx_speed")[1]:set_markup(
			'<span font="'..NUMBER_FONT..'" foreground="#eb6f92">' .. convert_to_h(total_tx / timeout) .. "</span>"
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

