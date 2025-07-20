local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local widget_font = "Fira Sans Bold 14"

local gpu_icon = wibox.widget({
	markup = '<span foreground="#2de6e2"> 󰍹 </span>',
	font = widget_font,
	widget = wibox.widget.textbox,
})

local gpu_text = wibox.widget({
	markup = '<span foreground="#beef00">--%</span>',
	font = widget_font,
	widget = wibox.widget.textbox,
})

local gpu_widget = wibox.widget({
	gpu_icon,
	gpu_text,
	spacing = 4,
	layout = wibox.layout.fixed.horizontal,
})

local function update_gpu_widget()
	awful.spawn.easy_async_with_shell(
		[[doas intel_gpu_top -c -s 1000 -o - 2>/dev/null | awk -F, 'NR>2 {print $15; exit}']],
		function(out)
			local percent = tonumber(out)
			if percent then
				local percent_int = tostring(math.floor(percent + 0.5))
				gpu_text.markup = string.format('<span foreground="#beef00">%s%%</span>', percent_int)
			else
				gpu_text.markup = '<span foreground="#beef00">--%%</span>'
			end
		end
	)
end

gears.timer({
	timeout = 1,
	autostart = true,
	call_now = true,
	callback = update_gpu_widget,
})

return gpu_widget
