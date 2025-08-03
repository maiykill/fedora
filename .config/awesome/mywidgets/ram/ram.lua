local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

-- Theme colors inspired by Rose Pine
local themecolors = {
	bg = "#232136", -- dark background
	fg = "#e0def4", -- light foreground
  bord = "#8839ef",
	cached= "#74c7ec", -- yellow-ish
  used = "#a6d189", -- green-ish
	avail = "#f9e2af", -- teal-ish
	swap = "#fe8019", -- orange-ish
	icon = "#2dece2", -- cyan-ish
}

-- Fonts
local themefonts = {
	icon = "FiraCode Nerd Font Propo Bold 13",
	text = "FiraCode Nerd Font Propo Bold 13",
	tooltip_title = "Fira Sans 14",
	tooltip_text = "Fira Sans Bold 15",
}

-- Icons
local themeicons = {
	ram = "",
}

local function human_readable(kb)
	kb = tonumber(kb)
	if not kb then
		return "--"
	end
	local mb = kb / 1024
	if mb >= 1024 then
		return string.format("%.2fG", mb / 1024)
	else
		return string.format("%.2fM", mb)
	end
end

-- Visible RAM widget: icon + used percent + used size
local ram_text = wibox.widget({
	markup = string.format(
		'<span font="%s" color="%s">%s</span> '
			.. '<span font="%s" color="%s">--%%</span> '
			.. '<span font="%s" color="%s">--</span>',
		themefonts.icon,
		themecolors.icon,
		themeicons.ram,
		themefonts.text,
		themecolors.used,
		themefonts.text,
		themecolors.used
	),
	align = "center",
	widget = wibox.widget.textbox,
})

local ram_widget = wibox.widget({
	ram_text,
	bg = themecolors.bg,
	fg = themecolors.fg,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
})

-- Even more rounded tooltip box (radius = 40)
local tooltip_wibox = wibox({
	ontop = true,
	visible = false,
	bg = themecolors.bg,
	fg = themecolors.fg,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 40)
	end,
	border_width = 2,
	border_color = themecolors.bord,
	width = 500,
	height = 270,
	minimum_width = 480,
	minimum_height = 270,
})

-- Arcchart widget with thickened border
local arcchart = wibox.container.arcchart()
arcchart.forced_width = 175
arcchart.forced_height = 175
arcchart.bg = themecolors.bg
arcchart.border_color = themecolors.fg
arcchart.border_width = 0
arcchart.thickness = 40
arcchart.rounded_edge = true
arcchart.start_angle = math.pi * 1.5

arcchart.values = { 0, 0, 0, 0 }
arcchart.colors = {
	themecolors.used,
	themecolors.cached,
	themecolors.avail,
	themecolors.swap,
}

-- Text labels for detailed metrics
local used_label = wibox.widget.textbox()
local cached_label = wibox.widget.textbox()
local avail_label = wibox.widget.textbox()
local swap_label = wibox.widget.textbox()

local labels_layout = wibox.widget({
	layout = wibox.layout.fixed.vertical,
	spacing = 10,
	used_label,
	cached_label,
	avail_label,
	swap_label,
})

local labels_margin = wibox.container.margin(labels_layout, 10, 10, 10, 10)
local labels_centered = wibox.container.place(labels_margin)
labels_centered.valign = "center"

local content_layout = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	spacing = 40,
	arcchart,
	labels_centered,
})

local content_centered = wibox.container.place(content_layout)
content_centered.valign = "center"

tooltip_wibox:setup({
	margins = 20,
	widget = wibox.container.margin,
	content_centered,
})

local function show_tooltip()
	local m = mouse and mouse.coords()
	if not m then
		tooltip_wibox.visible = false
		return
	end

	local s = awful.screen.focused()
	local screen_geom = s and s.geometry or { x = 0, y = 0, width = 1920, height = 1080 }

	local w = tooltip_wibox.width or tooltip_wibox.minimum_width or 480
	local h = tooltip_wibox.height or tooltip_wibox.minimum_height or 270

	local x = m.x + 25
	local y = m.y + 25

	if x + w > screen_geom.x + screen_geom.width then
		x = m.x - w - 25
		if x < screen_geom.x then
			x = screen_geom.x
		end
	end
	if y + h > screen_geom.y + screen_geom.height then
		y = m.y - h - 25
		if y < screen_geom.y then
			y = screen_geom.y
		end
	end

	tooltip_wibox.x = x
	tooltip_wibox.y = y
	tooltip_wibox.visible = true
end

local function hide_tooltip()
	tooltip_wibox.visible = false
end

local function update_ram()
	awful.spawn.easy_async_with_shell("LANG=C free | rg 'Mem|Swap'", function(out)
		local mem_total, mem_used, mem_free, mem_shared, mem_buffcache, mem_available =
			out:match("Mem:%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
		local swap_total, swap_used, swap_free = out:match("Swap:%s+(%d+)%s+(%d+)%s+(%d+)")

		if mem_total and mem_used and mem_buffcache and mem_available and swap_total and swap_used then
			mem_total = tonumber(mem_total)
			mem_used = tonumber(mem_used)
			mem_buffcache = tonumber(mem_buffcache)
			mem_available = tonumber(mem_available)
			swap_total = tonumber(swap_total)
			swap_used = tonumber(swap_used)

			local used_p = math.floor(mem_used / mem_total * 100)
			local cached_p = math.floor(mem_buffcache / mem_total * 100)
			local avail_p = math.floor(mem_available / mem_total * 100)
			local swap_p = (swap_total > 0) and math.floor(swap_used / swap_total * 100) or 0

			local used_s = human_readable(mem_used)
			local cached_s = human_readable(mem_buffcache)
			local avail_s = human_readable(mem_available)
			local swap_s = (swap_total > 0) and human_readable(swap_used) or "--"

			ram_text.markup = string.format(
				'<span font="%s" color="%s">%s</span> '
					.. '<span font="%s" color="%s">%d%%</span> '
					.. '<span font="%s" color="%s">%s</span>',
				themefonts.icon,
				themecolors.icon,
				themeicons.ram,
				themefonts.text,
				themecolors.used,
				used_p,
				themefonts.text,
				themecolors.used,
				used_s
			)
			arcchart.values = { used_p, cached_p, avail_p, swap_p }
			used_label:set_markup(
				string.format(
					'<span foreground="%s" font="%s"><b>Used:</b> %d%% (%s)</span>',
					themecolors.used,
					themefonts.tooltip_text,
					used_p,
					used_s
				)
			)
			cached_label:set_markup(
				string.format(
					'<span foreground="%s" font="%s"><b>Cached:</b> %d%% (%s)</span>',
					themecolors.cached,
					themefonts.tooltip_text,
					cached_p,
					cached_s
				)
			)
			avail_label:set_markup(
				string.format(
					'<span foreground="%s" font="%s"><b>Available:</b> %d%% (%s)</span>',
					themecolors.avail,
					themefonts.tooltip_text,
					avail_p,
					avail_s
				)
			)
			swap_label:set_markup(
				string.format(
					'<span foreground="%s" font="%s"><b>Swap:</b> %d%% (%s)</span>',
					themecolors.swap,
					themefonts.tooltip_text,
					swap_p,
					swap_s
				)
			)
		else
			ram_text.markup = string.format(
				'<span font="%s" color="%s">%s</span> '
					.. '<span font="%s" color="%s">--%%</span> '
					.. '<span font="%s" color="%s">--</span>',
				themefonts.icon,
				themecolors.icon,
				themeicons.ram,
				themefonts.text,
				themecolors.used,
				themefonts.text,
				themecolors.used
			)
			arcchart.values = { 0, 0, 0, 0 }
			used_label:set_markup("<i>RAM details unavailable</i>")
			cached_label:set_markup("")
			avail_label:set_markup("")
			swap_label:set_markup("")
		end
	end)
end

ram_widget:connect_signal("mouse::enter", show_tooltip)
ram_widget:connect_signal("mouse::leave", hide_tooltip)

gears.timer({
	timeout = 2,
	autostart = true,
	call_now = true,
	callback = update_ram,
})

return ram_widget
