local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local uptime_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	-- valign = "center",
	font = "Fira Sans Bold 14",
})

local function update_uptime()
	awful.spawn.easy_async_with_shell("awk '{print int($1)}' /proc/uptime", function(stdout)
		local total_seconds = tonumber(stdout) or 0
		local days = math.floor(total_seconds / 86400)
		local hours = math.floor((total_seconds % 86400) / 3600)
		local minutes = math.floor((total_seconds % 3600) / 60)
		local text = ""
		if days > 0 then
			text = string.format(" %dd%02dh%02dm ", days, hours, minutes)
		elseif hours > 0 then
			text = string.format(" %dh%02dm ", hours, minutes)
		else
			text = string.format(" %dm ", minutes)
		end
		uptime_widget.markup = '<span foreground="#f6c177">' .. text .. "</span>"
	end)
end

gears.timer({
	timeout = 60,
	autostart = true,
	call_now = true,
	callback = update_uptime,
})

return uptime_widget
