local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

-- Mixed palette colors
local color_bg     = "#232136"    -- dark background (from Rose Pine)
local color_fg     = "#e0def4"    -- light foreground (from Rose Pine)
local color_used   = "#f9e2af"    -- Catppuccin Mocha yellow
local color_cached = "#8bd5ca"    -- Catppuccin Macchiato teal
local color_avail  = "#a3be8c"    -- Nord green
local color_swap   = "#fe8019"    -- Gruvbox orange
local color_icon   = "#f5c2e7"    -- Catppuccin Mocha pink

local font_icon = "FiraCode Nerd Font 14"
local font_text = "Fira Sans Bold 14"

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

local ram_text = wibox.widget({
	markup = string.format(
		'<span font="%s" color="%s"></span> <span font="%s"><span color="%s">--%% (--)</span>   <span color="%s">--%% (--)</span>   <span color="%s">--%% (--)</span>   <span color="%s">--%% (--)</span></span>',
		font_icon,
		color_avail,
		font_text,
		color_used,
		color_cached,
		color_avail,
		color_swap
	),
	align = "left",
	widget = wibox.widget.textbox,
})

local ram_widget = wibox.widget({
	{
		ram_text,
		layout = wibox.layout.fixed.horizontal,
	},
	bg = color_bg,
	fg = color_fg,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
	set_text = function(self, used_p, used, cached_p, cached, avail_p, avail, swap_p, swap)
		ram_text.markup = string.format(
			'<span font="%s" color="%s">  </span> <span font="%s"><span color="%s">%d%% (%s)</span> <span color="%s">%d%% (%s)</span> <span color="%s">%d%% (%s)</span> <span color="%s">%d%% (%s)</span></span>',
			font_icon,
			color_avail,
			font_text,
			color_used,
			used_p,
			used,
			color_cached,
			cached_p,
			cached,
			color_avail,
			avail_p,
			avail,
			color_swap,
			swap_p,
			swap
		)
	end,
})

local function update_ram()
	awful.spawn.easy_async_with_shell("LANG=C free | grep -E 'Mem|Swap'", function(out)
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

			ram_widget:set_text(used_p, used_s, cached_p, cached_s, avail_p, avail_s, swap_p, swap_s)
		else
			ram_widget:set_text(0, "--", 0, "--", 0, "--", 0, "--")
		end
	end)
end

gears.timer({
	timeout = 2,
	autostart = true,
	call_now = true,
	callback = update_ram,
})

return ram_widget
