local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

-- Theme colors table
local themecolors = {
	icon_fg = "#2de6e2",
	percent_fg = "#beef00",
}

-- Theme fonts table
local themefonts = {
	widget = "FiraCode Nerd Font Propo Bold 13",
}

local function worker(args)
	local args = args or {}
	local forced_width = args.width or 60 -- width only applied to the percentage textbox

	local gpu_icon = wibox.widget({
		markup = string.format('<span foreground="%s">󰍹</span>', themecolors.icon_fg),
		font = themefonts.widget,
		-- No forced_width here to avoid extra space
		align = "center",
		widget = wibox.widget.textbox,
	})

	local gpu_text = wibox.widget({
		markup = string.format('<span foreground="%s">--%%</span>', themecolors.percent_fg),
		font = themefonts.widget,
		forced_width = forced_width, -- only here
		align = "center",
		widget = wibox.widget.textbox,
	})

	local gpu_widget = wibox.widget({
		gpu_icon,
		gpu_text,
		spacing = 0, -- no extra spacing
		layout = wibox.layout.fixed.horizontal,
	})

	local function update_gpu_widget()
		awful.spawn.easy_async_with_shell(
			[[doas intel_gpu_top -c -s 1000 -o - 2>/dev/null | awk -F, 'NR>2 {print $15; exit}']],
			function(out)
				local percent = tonumber(out)
				if percent then
					local percent_int = tostring(math.floor(percent + 0.5))
					gpu_text.markup =
						string.format('<span foreground="%s">%s%%</span>', themecolors.percent_fg, percent_int)
				else
					gpu_text.markup = string.format('<span foreground="%s">--%%</span>', themecolors.percent_fg)
				end
			end
		)
	end

	local timer = gears.timer({
		timeout = 1,
		autostart = true,
		call_now = true,
		callback = update_gpu_widget,
	})

	gpu_widget._timer = timer

	return gpu_widget
end

return setmetatable({}, {
	__call = function(_, ...)
		return worker(...)
	end,
})
