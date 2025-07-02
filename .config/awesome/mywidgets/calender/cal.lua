local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

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

local clock = wibox.widget.textclock(
	'<span foreground="#D8DEE9"> %A of %B %d.%m.%Y</span>  <span foreground="#fab795">%H:%M:%S </span>',
	1
)
clock.font = "Fira Sans Bold 14"

local font_header = "FiraCode Nerd Font Bold 16"
local font_week = "FiraCode Nerd Font Bold 15"
local font_day = "FiraCode Nerd Font Bold 14"

local function month_table(year, month)
	local first_day = os.time({ year = year, month = month, day = 1 })
	local first_wday = tonumber(os.date("%w", first_day))
	local start_col = (first_wday == 0) and 7 or first_wday
	start_col = (start_col == 7) and 1 or start_col + 1
	local days_in_month = tonumber(os.date("%d", os.time({ year = year, month = month + 1, day = 0 })))
	local today = tonumber(os.date("%d"))
	local this_month = tonumber(os.date("%m"))
	local this_year = tonumber(os.date("%Y"))
	local weeks, week, day = {}, {}, 1
	for i = 1, 7 do
		if i < start_col then
			week[i] = ""
		else
			week[i] = day
			day = day + 1
		end
	end
	table.insert(weeks, week)
	while day <= days_in_month do
		week = {}
		for i = 1, 7 do
			if day <= days_in_month then
				week[i] = day
				day = day + 1
			else
				week[i] = ""
			end
		end
		table.insert(weeks, week)
	end
	return weeks, today, this_month, this_year
end

local popup = nil
local cal_state = { month = tonumber(os.date("%m")), year = tonumber(os.date("%Y")) }
local cal_grid, header_widget

local function update_calendar_content()
	local year, month = cal_state.year, cal_state.month
	local weeks, today, this_month, this_year = month_table(year, month)
	local weekday_names = { "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su" }

	header_widget.markup = '<span foreground="'
		.. outrun.header_fg
		.. '">'
		.. os.date("%B %Y", os.time({ year = year, month = month, day = 1 }))
		.. "</span>"
	header_widget.font = font_header
	cal_grid:reset()

	for i = 1, 7 do
		local fg = (i == 6 or i == 7) and outrun.header_fg or outrun.weekday_fg
		cal_grid:add_widget_at(
			wibox.widget({
				markup = '<b><span foreground="' .. fg .. '">' .. weekday_names[i] .. "</span></b>",
				align = "center",
				valign = "center",
				widget = wibox.widget.textbox,
				font = font_week,
			}),
			1,
			i
		)
	end

	for row = 1, #weeks do
		for col = 1, 7 do
			local d = weeks[row][col]
			local is_today = (d ~= "" and d == today and month == this_month and year == this_year)
			local is_weekend = (col == 6 or col == 7)
			local fg = outrun.fg
			local bg = outrun.bg
			local cell_shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, 6)
			end

			if is_today then
				cal_grid:add_widget_at(
					wibox.widget({
						{
							text = tostring(d),
							align = "center",
							valign = "center",
							font = font_day,
							widget = wibox.widget.textbox,
							markup = '<span foreground="' .. outrun.focus_date_fg .. '">' .. d .. "</span>",
						},
						bg = outrun.focus_date_bg,
						shape = cell_shape,
						widget = wibox.container.background,
					}),
					row + 1,
					col
				)
			elseif is_weekend and d ~= "" then
				cal_grid:add_widget_at(
					wibox.widget({
						{
							text = tostring(d),
							align = "center",
							valign = "center",
							font = font_day,
							widget = wibox.widget.textbox,
							markup = '<span foreground="' .. outrun.fg .. '">' .. d .. "</span>",
						},
						bg = outrun.weekend_day_bg,
						shape = cell_shape,
						widget = wibox.container.background,
					}),
					row + 1,
					col
				)
			elseif d ~= "" then
				cal_grid:add_widget_at(
					wibox.widget({
						{
							text = tostring(d),
							align = "center",
							valign = "center",
							font = font_day,
							widget = wibox.widget.textbox,
							markup = '<span foreground="' .. outrun.fg .. '">' .. d .. "</span>",
						},
						bg = outrun.bg,
						shape = cell_shape,
						widget = wibox.container.background,
					}),
					row + 1,
					col
				)
			else
				cal_grid:add_widget_at(
					wibox.widget({
						text = " ",
						align = "center",
						valign = "center",
						font = font_day,
						widget = wibox.widget.textbox,
					}),
					row + 1,
					col
				)
			end
		end
	end
end

local function create_popup()
	header_widget = wibox.widget({
		align = "center",
		font = font_header,
		widget = wibox.widget.textbox,
	})
	cal_grid = wibox.widget({
		layout = wibox.layout.grid,
		homogeneous = true,
		spacing = 11,
		forced_num_cols = 7,
		expand = true,
		align = "center",
	})
	local calendar_popup = awful.popup({
		type = "dock",
		ontop = true,
		visible = false,
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, 32)
		end,
		bg = outrun.bg,
		border_width = 3,
		border_color = outrun.border,
		widget = {
			{
				{
					header_widget,
					cal_grid,
					spacing = 14,
					layout = wibox.layout.fixed.vertical,
				},
				margins = 24,
				widget = wibox.container.margin,
			},
			bg = outrun.bg,
			widget = wibox.container.background,
		},
		placement = function(w)
			awful.placement.top_right(w, { margins = { top = 60, right = 40 } })
		end,
		minimum_width = 410,
		maximum_width = 410,
		minimum_height = 310,
		maximum_height = 350,
	})
	return calendar_popup
end

local function show_popup()
	if not popup then
		popup = create_popup()
		popup:connect_signal("button::press", function(_, _, _, button)
			if button == 1 then
				cal_state.month = cal_state.month + 1
				if cal_state.month > 12 then
					cal_state.month = 1
					cal_state.year = cal_state.year + 1
				end
				update_calendar_content()
			elseif button == 3 then
				cal_state.month = cal_state.month - 1
				if cal_state.month < 1 then
					cal_state.month = 12
					cal_state.year = cal_state.year - 1
				end
				update_calendar_content()
			end
		end)
	end
	update_calendar_content()
	popup.visible = true
end

clock:connect_signal("button::press", function(_, _, _, button)
	if button == 1 then
		if popup and popup.visible then
			popup.visible = false
			cal_state.month = tonumber(os.date("%m"))
			cal_state.year = tonumber(os.date("%Y"))
		else
			cal_state.month = tonumber(os.date("%m"))
			cal_state.year = tonumber(os.date("%Y"))
			show_popup()
		end
	end
end)

return clock
