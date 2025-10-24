local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local themecolors = {
	bg = "#232136",
	fg = "#e0def4",
	netdown = "#9ccfd8",
	netup = beautiful.nord_orange,
}
local themefonts = {
	icon = "Iosevka Term Extended Bold 14",
	text = "Iosevka Term Extended Bold 14",
}

local icons = {
	down = "󰇚",
	up = "󰕒",
}

local netdown_text = wibox.widget.textbox("--.-- " .. icons.down)
netdown_text.font = themefonts.text
netdown_text.halign = "center"

local netdown_capsule = wibox.widget({
	{
		netdown_text,
		left = 1,
		right = 1,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0 or themecolors.bg,
	fg = themecolors.netdown,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
	forced_width = 75,
})

local netup_text = wibox.widget.textbox("--.-- " .. icons.up)
netup_text.font = themefonts.text
netup_text.halign = "center"

local netup_capsule = wibox.widget({
	{
		netup_text,
		left = 1,
		right = 1,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0 or themecolors.bg,
	fg = themecolors.netup,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
	forced_width = 75,
})

local netspeed_widget = wibox.widget({
	netdown_capsule,
	{ text = " ", widget = wibox.widget.textbox },
	netup_capsule,
	layout = wibox.layout.fixed.horizontal,
})

-- Efficient pure-Lua network interface enumerator via /proc/net/dev
local function get_interfaces()
	local ifaces = {}
	local f = io.open("/proc/net/dev", "r")
	if not f then
		return ifaces
	end
	for line in f:lines() do
		local iface = line:match("^%s*([%w%-%_]+):")
		if iface and iface ~= "lo" and not iface:match("^docker") and not iface:match("^vbox") then
			table.insert(ifaces, iface)
		end
	end
	f:close()
	return ifaces
end

local function get_active_interface()
	for _, iface in ipairs(get_interfaces()) do
		local opf = io.open("/sys/class/net/" .. iface .. "/operstate", "r")
		local carrierf = io.open("/sys/class/net/" .. iface .. "/carrier", "r")
		local state = opf and opf:read("*l") or nil
		local carrier = carrierf and carrierf:read("*l") or nil
		if opf then
			opf:close()
		end
		if carrierf then
			carrierf:close()
		end
		if (state == "up" or state == "unknown") and carrier == "1" then
			return iface
		elseif state == "up" or state == "unknown" then
			return iface
		end
	end
	return nil
end

local function read_stat(iface, stat)
	local path = "/sys/class/net/" .. iface .. "/statistics/" .. stat
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*l")
	f:close()
	return tonumber(content)
end

local function get_net_stats(iface)
	local rx = read_stat(iface, "rx_bytes")
	local tx = read_stat(iface, "tx_bytes")
	return rx, tx
end

local prev_rx, prev_tx, prev_time, prev_iface = nil, nil, nil, nil

local function format_speed(bytes)
	if not bytes then
		return "--.--"
	elseif bytes < 1024 then
		return string.format("%4dB", bytes)
	elseif bytes < (10 * 1024) then
		return string.format("%.2fK", bytes / 1024)
	elseif bytes < (100 * 1024) then
		return string.format("%.1fK", bytes / 1024)
	elseif bytes < 1024 * 1024 then
		return string.format("%.0fK", bytes / 1024)
	elseif bytes < (10 * 1024 * 1024) then
		return string.format("%.2fM", bytes / (1024 * 1024))
	elseif bytes < (100 * 1024 * 1024) then
		return string.format("%.1fM", bytes / (1024 * 1024))
	elseif bytes < 1024 * 1024 * 1024 then
		return string.format("%.0fM", bytes / (1024 * 1024))
	else
		return string.format("%.1fG", bytes / (1024 * 1024 * 1024))
	end
end

local function update_widget()
	local iface = get_active_interface()
	local now = os.time()
	if iface then
		local rx, tx = get_net_stats(iface)
		if rx and tx and prev_rx and prev_tx and prev_time and prev_iface == iface then
			local dt = now - prev_time
			if dt > 0 then
				local rx_speed = (rx - prev_rx) / dt
				local tx_speed = (tx - prev_tx) / dt
				netdown_text.text = format_speed(math.max(0, rx_speed)) .. icons.down
				netup_text.text = format_speed(math.max(0, tx_speed)) .. icons.up
			else
				netdown_text.text = "--.-- " .. icons.down
				netup_text.text = "--.-- " .. icons.up
			end
		else
			netdown_text.text = "--.-- " .. icons.down
			netup_text.text = "--.-- " .. icons.up
		end
		prev_rx, prev_tx, prev_time, prev_iface = rx, tx, now, iface
	else
		netdown_text.text = "--.-- " .. icons.down
		netup_text.text = "--.-- " .. icons.up
		prev_rx, prev_tx, prev_time, prev_iface = nil, nil, nil, nil
	end
end

gears.timer({
	timeout = 1,
	autostart = true,
	call_now = true,
	callback = update_widget,
})

return netspeed_widget
