local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local themefonts = {
	text = "Iosevka Term Extended Bold 14",
}

local icon_unmuted = "🔊"
local icon_muted = "🔇"

local volume_text = wibox.widget.textbox()
volume_text.font = themefonts.text
volume_text.halign = "center"
volume_text.valign = "center"

local volume_capsule = wibox.widget({
	{
		volume_text,
		left = 7,
		right = 2,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin,
	},
	bg = beautiful.cat_surface0,
	fg = beautiful.cat_teal,
	shape = gears.shape.rounded_rect,
	widget = wibox.container.background,
	forced_width = 70,
})

-- Parse volume and mute status from amixer output

local function get_volume_info()
	local f_vol = io.popen("wpctl get-volume @DEFAULT_AUDIO_SINK@")
	if not f_vol then
		return nil, nil
	end
	local vol_str = f_vol:read("*all")
	f_vol:close()

	-- Extract volume decimal number
	local volume = tonumber(vol_str:match("Volume:%s*([0-9]*%.?[0-9]+)"))

	-- Determine mute state by presence of [MUTED]
	local muted = vol_str:find("%[MUTED%]") ~= nil

	if not volume then
		volume = 0
	end

	-- Convert volume decimal (0.0-1.0) to percentage
	volume = math.floor(volume * 100)

	return volume, muted
end

-- Update function
local function update_volume()
	local volume, muted = get_volume_info()
	if not volume then
		volume_text.text = "N/A " .. icon_muted
		volume_capsule.bg = beautiful.kana_samuraired
		return
	end

	local icon = muted and icon_muted or icon_unmuted
	volume_text.text = string.format("%d%%%s", volume, icon)

	if muted then
		volume_capsule.bg = beautiful.kana_samuraired
	else
		volume_capsule.bg = beautiful.cat_surface0
	end
end

-- Timer to update volume every 0.5 seconds (adjust if needed)
gears.timer({
	timeout = 0.5,
	autostart = true,
	call_now = true,
	callback = update_volume,
})

return volume_capsule
