local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local mytextclock = wibox.widget.textclock("%a,%b,%d.%m.%Y %H:%M:%S", 1)
mytextclock.font = beautiful.alternateboldfont
local clock_widget = wibox.widget({
	{
		mytextclock,
		left = 7,
		right = 3,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0 or "#232136",
	fg = beautiful.cat_text,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
	forced_width = 335,
})

return clock_widget
