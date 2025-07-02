local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local outrun = {
	bg = "#0d0221",
	fg = "#D8DEE9",
	focus_date_bg = "#650d89",
	focus_date_fg = "#2de6e2",
	weekend_day_bg = "#261447",
	weekday_fg = "#2de6e2",
	header_fg = "#f6019d",
	border = "#261447",
}

-- Utility: get active port using your preferred command
local function get_device_icon_and_name(callback)
	awful.spawn.easy_async_with_shell(
		[[pactl list sinks | rg -e "Active Port" | awk -F'-' '{print $NF}' | head -n1]],
		function(port)
			port = port:gsub("\n", ""):lower()
			local icon, label
			if port:find("headphone") then
				icon = "🎧"
				label = "Headphones"
			elseif port:find("speaker") then
				icon = "🔊"
				label = "Speakers"
			elseif port:find("hdmi") then
				icon = "🖥️"
				label = "HDMI"
			elseif port:find("usb") then
				icon = "🔈"
				label = "USB"
			elseif port ~= "" then
				icon = "🔊"
				label = port:gsub("_", " "):gsub("^%l", string.upper)
			else
				icon = "🔊"
				label = "Speakers"
			end
			callback(icon, label)
		end
	)
end

-- Widget parts
local volume_icon = wibox.widget({
	markup = "🔊",
	font = "Fira Sans Bold 16",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})
local volume_text = wibox.widget({
	markup = "0",
	font = "Fira Sans Bold 14",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})
local volume_widget = wibox.widget({
	{
		volume_icon,
		volume_text,
		spacing = 4,
		layout = wibox.layout.fixed.horizontal,
	},
	widget = wibox.container.margin,
	left = 8,
	right = 8,
	top = 2,
	bottom = 2,
	bg = outrun.bg,
})

-- Notification helper
local last_muted = nil
local function send_mute_notification(muted)
	if muted then
		awful.spawn("dunstify -a Volume -u critical -t 1500 'Muted' 'Audio is muted'")
	else
		awful.spawn("dunstify -a Volume -u low -t 1500 'Unmuted' 'Audio is unmuted'")
	end
end

-- Widget updater
local function update_volume_widget(send_notification)
	awful.spawn.easy_async_with_shell("wpctl get-volume @DEFAULT_AUDIO_SINK@", function(stdout)
		local volume = stdout:match("(%d%.%d+)")
		local muted = stdout:find("MUTED")
		if volume then
			local percent = math.floor(tonumber(volume) * 100)
			if muted then
				volume_icon.markup = '<span foreground="' .. outrun.header_fg .. '">🔇</span>'
				volume_text.markup = '<span foreground="' .. outrun.header_fg .. '">' .. percent .. "</span>"
			else
				volume_icon.markup = '<span foreground="' .. outrun.fg .. '">🔊</span>'
				volume_text.markup = '<span foreground="' .. outrun.fg .. '">' .. percent .. "</span>"
			end
			if send_notification and last_muted ~= nil and muted ~= last_muted then
				send_mute_notification(muted)
			end
			last_muted = muted
		else
			volume_icon.markup = '<span foreground="' .. outrun.fg .. '">--</span>'
			volume_text.markup = '<span foreground="' .. outrun.fg .. '">--</span>'
		end
	end)
end

-- Initial update and timer
update_volume_widget(false)
gears.timer({
	timeout = 5,
	autostart = true,
	call_now = true,
	callback = function()
		update_volume_widget(false)
	end,
})
gears.timer({
	timeout = 0.5,
	autostart = true,
	callback = function()
		update_volume_widget(true)
	end,
})

-- Popup slider with icon, device, and percent
local slider_icon = wibox.widget({
	markup = "🔊",
	font = "Fira Sans Bold 18",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})
local slider_device = wibox.widget({
	markup = "Speakers",
	font = "Fira Sans 12",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})
local slider_percent = wibox.widget({
	markup = "0%",
	font = "Fira Sans Bold 16",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local slider = wibox.widget({
	bar_shape = gears.shape.rounded_rect,
	bar_height = 18,
	bar_color = outrun.weekend_day_bg,
	bar_active_color = outrun.header_fg,
	handle_color = outrun.focus_date_fg,
	handle_shape = gears.shape.circle,
	handle_width = 28,
	minimum = 0,
	maximum = 100,
	value = 50,
	widget = wibox.widget.slider,
})

local slider_row = wibox.widget({
	slider_icon,
	slider_device,
	slider,
	slider_percent,
	spacing = 14,
	layout = wibox.layout.fixed.horizontal,
})

local slider_popup = awful.popup({
	widget = {
		{
			slider_row,
			forced_width = 370,
			forced_height = 60,
			widget = wibox.container.margin,
			margins = 16,
		},
		bg = outrun.bg,
		shape = gears.shape.rounded_rect,
		widget = wibox.container.background,
	},
	visible = false,
	ontop = true,
	shape = gears.shape.rounded_rect,
	border_width = 2,
	border_color = outrun.border,
	placement = function(popup)
		awful.placement.next_to(popup, {
			preferred_positions = { "bottom" },
			preferred_alignments = { "middle" },
			geometry = mouse.current_widget_geometry or mouse.coords(),
			parent = mouse.screen,
		})
	end,
})

-- Popup hide logic: always hide after 2s if mouse is not on popup
local hide_timer = gears.timer({
	timeout = 2,
	single_shot = true,
	callback = function()
		slider_popup.visible = false
	end,
})

slider_popup.widget:connect_signal("mouse::enter", function()
	hide_timer:stop()
end)
slider_popup.widget:connect_signal("mouse::leave", function()
	hide_timer:again()
end)

local function set_volume(percent)
	awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. (percent / 100))
	gears.timer.start_new(0.1, function()
		update_volume_widget(false)
		slider_percent.markup = '<span foreground="' .. outrun.fg .. '">' .. percent .. "%%</span>"
		return false
	end)
end

slider:connect_signal("property::value", function()
	set_volume(slider.value)
end)

-- Only activate popup on left click, not on scroll
volume_widget:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn.easy_async_with_shell("wpctl get-volume @DEFAULT_AUDIO_SINK@", function(stdout)
		local volume = stdout:match("(%d%.%d+)")
		local muted = stdout:find("MUTED")
		local percent = volume and math.floor(tonumber(volume) * 100) or 0
		get_device_icon_and_name(function(dev_icon, dev_label)
			slider.value = percent
			slider_device.markup = '<span foreground="' .. outrun.focus_date_fg .. '">' .. dev_label .. "</span>"
			if muted then
				slider_icon.markup = '<span foreground="' .. outrun.header_fg .. '">🔇</span>'
				slider_percent.markup = '<span foreground="' .. outrun.header_fg .. '">' .. percent .. "%%</span>"
			else
				slider_icon.markup = '<span foreground="' .. outrun.fg .. '">' .. dev_icon .. "</span>"
				slider_percent.markup = '<span foreground="' .. outrun.fg .. '">' .. percent .. "%%</span>"
			end
			slider_popup.visible = not slider_popup.visible
			if slider_popup.visible then
				slider_popup:move_next_to(mouse.current_widget_geometry)
				-- Do not start the timer immediately; wait for mouse leave
			else
				hide_timer:stop()
			end
		end)
	end)
end)))

return volume_widget
