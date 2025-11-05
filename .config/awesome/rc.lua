-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Reduce noice in this file
local awesome, client, root, screen = awesome, client, root, screen

-- -- {{{ Error handling
-- -- Check if awesome encountered an error during startup and fell back to
-- -- another config (This code will only ever execute for the fallback config)
-- if awesome.startup_errors then
-- 	naughty.notify({
-- 		preset = naughty.config.presets.critical,
-- 		title = "Oops, there were errors during startup!",
-- 		text = awesome.startup_errors,
-- 	})
-- end
-- -- Handle runtime errors after startup
-- do
-- 	local in_error = false
-- 	awesome.connect_signal("debug::error", function(err)
-- 		-- Make sure we don't go into an endless error loop
-- 		if in_error then
-- 			return
-- 		end
-- 		in_error = true
--
-- 		naughty.notify({
-- 			preset = naughty.config.presets.critical,
-- 			title = "Oops, an error happened!",
-- 			text = tostring(err),
-- 		})
-- 		in_error = false
-- 	end)
-- end
-- -- Error handling }}}

-- M.
-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- beautiful.init("/home/mike/.config/awesome/themes/default/theme.lua")
-- beautiful.init("/home/mike/.config/awesome/themes/xresources/theme.lua")
beautiful.init("/home/mike/.config/awesome/theme.lua")

beautiful.wallpaper = "/home/mike/Public/squares.png"

-- M. widgets
local cpu_widget = require("mywidgets.cpu.cpu")
local net_speed = require("mywidgets.net.net")
local ram_widget = require("mywidgets.ram.ram")
local battery_widget = require("mywidgets.battery.battery")
local volume_widget = require("mywidgets.volume.volume")
local filesystem_widget = require("mywidgets.filesystem.filesystem")
local clock_widget = require("mywidgets.time.time")

--- terminal = "xterm"
local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "vi"
local editor_cmd = terminal .. " -e " .. editor

-- M. Notification Configuration
-- Notification theming for "outrun" style and bigger size
-- beautiful.notification_bg = "#0d0221"
-- beautiful.notification_fg = "#D8DEE9"
-- beautiful.notification_border_color = "#261447"
-- beautiful.notification_border_width = 6
-- beautiful.notification_minimum_width = 400
-- beautiful.notification_minimum_height = 122
-- beautiful.notification_margin = 32
-- beautiful.notification_icon_size = 64
-- beautiful.notification_font = "Fira Sans Bold 16"
-- beautiful.notification_shape = function(cr, w, h)
-- 	gears.shape.rounded_rect(cr, w, h, 20)
-- end
-- beautiful.notification_critical_bg = "#650d89"
-- beautiful.notification_critical_fg = "#2de6e2"
-- naughty.config.defaults.shape = beautiful.notification_shape
-- naughty.config.defaults.width = beautiful.notification_width
-- naughty.config.defaults.height = beautiful.notification_height
-- naughty.config.defaults.margin = beautiful.notification_margin
-- naughty.config.defaults.border_width = beautiful.notification_border_width
-- naughty.config.defaults.border_color = beautiful.notification_border_color
-- naughty.config.defaults.bg = beautiful.notification_bg
-- naughty.config.defaults.fg = beautiful.notification_fg
-- naughty.config.defaults.icon_size = beautiful.notification_icon_size
-- naughty.config.presets.critical.bg = beautiful.notification_critical_bg
-- naughty.config.presets.critical.fg = beautiful.notification_critical_fg
-- -- naughty.config.defaults.position = "top_right"
-- naughty.config.defaults.stack_policy = "top"

-- Default modkey.
local superkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	awful.layout.suit.fair,

	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

local function show_volume_notification()
	-- Wait briefly to let the volume take effect
	gears.timer.start_new(0.1, function()
		awful.spawn.easy_async_with_shell("wpctl get-volume @DEFAULT_AUDIO_SINK@", function(stdout)
			local volume = stdout:match("(%d%.%d+)")
			local muted = stdout:find("MUTED")
			if volume then
				local percent = math.floor(tonumber(volume) * 100)
				local icon, urgency, text

				if muted then
					icon = "/usr/share/icons/HighContrast/scalable/status/audio-volume-muted.svg"
					urgency = "critical"
					text = percent .. "% (muted)"
				else
					icon = "/usr/share/icons/HighContrast/scalable/status/audio-volume-high.svg"
					urgency = "normal"
					text = percent .. "%"
				end

				awful.spawn(
					"dunstify -a Volume"
						.. " -u "
						.. urgency
						.. " -h int:value:"
						.. percent -- ✨ Progress bar hint here!
						.. " -i '"
						.. icon
						.. "'"
						.. " -r 9118" -- 🔁 Replace previous volume notification
						.. " -t 1500"
						.. " 'Volume' '"
						.. text
						.. "'"
				)
			end
		end)
		return false
	end)
end

local function show_brightness_notification()
	awful.spawn.easy_async_with_shell(
		[[
        brightnessctl get && brightnessctl max
        ]],
		function(stdout)
			local current, max = stdout:match("(%d+)\n(%d+)")
			if current and max then
				local percent = math.floor(tonumber(current) * 100 / tonumber(max) + 0.5)
				local icon = "/usr/share/icons/HighContrast/scalable/status/weather-clear.svg"
				awful.spawn(
					"dunstify -i '"
						.. icon
						.. "' -r 9119 -h int:value:"
						.. percent
						.. " 'Brightness' '"
						.. percent
						.. "%'"
				)
			end
		end
	)
end

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
	},
})

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
--
-- Create textclock widget with custom format and 1-second refresh

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ superkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ superkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end)
	-- awful.button({}, 4, function(t)
	-- 	awful.tag.viewnext(t.screen)
	-- end),
	-- awful.button({}, 5, function(t)
	-- 	awful.tag.viewprev(t.screen)
	-- end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, false)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	-- s.mypromptbox = awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	-- s.mylayoutbox = awful.widget.layoutbox(s)
	-- s.mylayoutbox:buttons(gears.table.join(
	-- 	awful.button({}, 1, function()
	-- 		awful.layout.inc(1)
	-- 	end),
	-- 	awful.button({}, 3, function()
	-- 		awful.layout.inc(-1)
	-- 	end),
	-- 	awful.button({}, 4, function()
	-- 		awful.layout.inc(1)
	-- 	end),
	-- 	awful.button({}, 5, function()
	-- 		awful.layout.inc(-1)
	-- 	end)
	-- ))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			-- mylauncher,
			s.mytaglist,
			-- s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			spacing = 3,
			-- mykeyboardlayout,
			wibox.widget.systray(),
			net_speed,
			cpu_widget,
			filesystem_widget,
			ram_widget,
			clock_widget,
      volume_widget,
			battery_widget,
			-- s.mylayoutbox,
		},
	})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end)
	-- awful.button({}, 4, awful.tag.viewnext),
	-- awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(
	-- awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ superkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ superkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	-- awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ superkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ superkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	-- awful.key({ modkey }, "w", function()
	-- 	mymainmenu:show()
	-- end, { description = "show main menu", group = "awesome" }),

	-- Volume controls with notification
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn.with_shell([[
        current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
        percent=$(echo "$current * 100" | bc)
        if [ "$(echo "$percent < 100" | bc)" -eq 1 ]; then
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        else
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
        fi
    ]])
		show_volume_notification()
	end, { description = "increase volume", group = "media" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
		show_volume_notification()
	end, { description = "decrease volume", group = "media" }),

	awful.key({}, "XF86AudioMute", function()
		awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
		show_volume_notification()
	end, { description = "toggle mute", group = "media" }),

	-- Brightness control with notification
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set +10%")
		show_brightness_notification()
	end, { description = "increase brightness", group = "media" }),

	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 10%-")
		show_brightness_notification()
	end, { description = "decrease brightness", group = "media" }),

	-- Layout manipulation
	awful.key({ superkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ superkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ superkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ superkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	-- awful.key(
	-- 	{ superkey },
	-- 	"u",
	-- 	awful.client.urgent.jumpto,
	-- 	{ description = "jump to urgent client", group = "client" }
	-- ),

	-- Standard program
	awful.key({ superkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ superkey }, "Home", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ superkey }, "Delete", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ superkey }, "]", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ superkey }, "[", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ superkey, "Shift" }, "[", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ superkey, "Shift" }, "]", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ superkey, "Control" }, "[", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ superkey, "Control" }, "]", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ superkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ superkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ superkey }, "comma", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- awful.key({ superkey }, "x", function()
	-- 	awful.prompt.run({
	-- 		prompt = "Run Lua code: ",
	-- 		textbox = awful.screen.focused().mypromptbox.widget,
	-- 		exe_callback = awful.util.eval,
	-- 		history_path = awful.util.get_cache_dir() .. "/history_eval",
	-- 	})
	-- end, { description = "lua execute prompt", group = "awesome" }),

	-- Menubar
	awful.key({ superkey }, "a", function()
		-- menubar.show()
		awful.spawn.with_shell(
			'rofi -dpi 150 -modi drun,run,window,ssh -show drun -font "Fira Sans 10" -show-icons -theme-str "element-icon { size: 1.5em; }" -display-drun "Apps: " -display-run "Run: " -display-window "Windows: " -display-ssh "SSH: "'
		)
	end, { description = "show the menubar", group = "launcher" }),

	-- Prompt
	awful.key({ superkey, "Shift" }, "a", function()
		-- awful.screen.focused().mypromptbox:run()
		awful.spawn.with_shell(
			'dmenu_run -fn "Fira Sans:style=Bold:size=14" -nb "#1F1D2E" -nf "#E0DEF4" -sb "#EB6F92" -sf "#E0DEF4" -b -i'
		)
	end, { description = "run prompt", group = "launcher" }),

	-- M. Custom key Bindings
	awful.key({ superkey }, "`", function()
		local fscreen = awful.screen.focused()
		local tag = fscreen.tags[5]
		if tag then
			tag:view_only()
		end
	end, { description = "go to tag 5", group = "tag" }),

	awful.key({ superkey, "Shift" }, "`", function()
		if client.focus then
			local tag = client.focus.screen.tags[5]
			if tag then
				client.focus:move_to_tag(tag)
			end
		end
	end, { description = "move focused client to tag 5", group = "tag" }),

	awful.key({ superkey }, "\\", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

	awful.key({ altkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	awful.key({ superkey, altkey }, "Return", function()
		awful.spawn("wezterm")
	end, { description = "wezterm terminal", group = "launcher" }),
	awful.key({ superkey, "Control" }, "Return", function()
		awful.spawn("kitty")
	end, { description = "kitty terminal", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "Return", function()
		awful.spawn("xfce4-terminal")
	end, { description = "xfce4-terminal", group = "launcher" }),
	awful.key({ superkey }, "q", function()
		awful.spawn("qbittorrent")
	end, { description = "qbittorrent", group = "launcher" }),
	awful.key({ superkey }, "h", function()
		awful.spawn("alacritty -e lf")
	end, { description = "lf in alacritty", group = "launcher" }),
	awful.key({ superkey, "Control" }, "Delete", function()
		awful.spawn("poweroff")
	end, { description = "poweroff", group = "system" }),
	awful.key({ superkey }, "l", function()
		awful.spawn("libreoffice")
	end, { description = "libreoffice", group = "launcher" }),
	awful.key({ superkey }, "g", function()
		awful.spawn("gimp")
	end, { description = "gimp", group = "launcher" }),
	awful.key({ superkey }, "v", function()
		awful.spawn("pavucontrol")
	end, { description = "pavucontrol", group = "launcher" }),
	awful.key({ superkey }, "p", function()
		awful.spawn("thunar")
	end, { description = "thunar", group = "launcher" }),
	awful.key({ superkey }, "e", function()
		awful.spawn("idle3")
	end, { description = "idle3", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "h", function()
		awful.spawn("xfce4-terminal -x lf")
	end, { description = "lf in xfce4-terminal", group = "launcher" }),
	awful.key({ superkey, "Control" }, "h", function()
		awful.spawn("kitty -e lf")
	end, { description = "lf in kitty", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "g", function()
		awful.spawn("inkscape")
	end, { description = "inkscape", group = "launcher" }),
	awful.key({ superkey, altkey }, "h", function()
		awful.spawn("wezterm -e lf")
	end, { description = "lf in wezterm", group = "launcher" }),
	awful.key({ superkey, "Control" }, "b", function()
		awful.spawn("firefox")
	end, { description = "firefox", group = "launcher" }),
	awful.key({ superkey, "Control", "Shift" }, "Return", function()
		awful.spawn("ghostty")
	end, { description = "ghostty", group = "launcher" }),
	awful.key({ superkey, "Control", "Shift" }, "h", function()
		awful.spawn("ghostty -e lf")
	end, { description = "lf in ghostty", group = "launcher" }),
	awful.key({ superkey, "Control" }, "m", function()
		awful.spawn("kitty -e btop")
	end, { description = "btop in kitty", group = "launcher" }),
	awful.key({ superkey, "Control", "Shift" }, "m", function()
		awful.spawn("ghostty -e btop")
	end, { description = "btop in ghostty", group = "launcher" }),
	awful.key({ superkey, altkey }, "m", function()
		awful.spawn("wezterm -e btop")
	end, { description = "btop in wezterm", group = "launcher" }),
	awful.key({ superkey }, "m", function()
		awful.spawn("alacritty -e btop")
	end, { description = "btop in alacritty", group = "launcher" }),
	awful.key({ superkey, altkey }, "b", function()
		awful.spawn(
			"chromium-browser --force-device-scale-factor=1.25 --use-angle=vulkan --enable-zero-copy--enable-gpu-rasterization --enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,UseMultiPlaneFormatForHardwareVideo,AcceleratedVideoDecodeLinuxZeroCopyGL"
		)
	end, { description = "chromium-browser", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "p", function()
		awful.spawn("pcmanfm")
	end, { description = "pcmanfm", group = "launcher" }),
	awful.key({ superkey }, "c", function()
		awful.spawn("ffplay -f v4l2 -input_format mjpeg -framerate 30 -video_size 1280x720 -i /dev/video0")
	end, { description = "ffplay webcam", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "c", function()
		awful.spawn("ffplay -f v4l2 -input_format mjpeg -framerate 30 -video_size 1280x720 -i /dev/video0 -vf hflip")
	end, { description = "ffplay webcam hflip", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "b", function()
		awful.spawn("floorp")
	end, { description = "floorp browser", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "Print", function()
		awful.spawn("scrot --focused '/home/mike/Downloads/%y%m%d_%H%M%S_$wx$h.png'")
	end, { description = "screenshot focused", group = "launcher" }),
	awful.key({ superkey, "Control" }, "Print", function()
		awful.spawn("scrot --select '/home/mike/Downloads/%y%m%d_%H%M%S_$wx$h.png'")
	end, { description = "screenshot select", group = "launcher" }),
	awful.key({ superkey }, "Print", function()
		awful.spawn("scrot '/home/mike/Downloads/%y%m%d_%H%M%S_$wx$h.png'")
	end, { description = "screenshot", group = "launcher" }),
	awful.key({ superkey }, "t", function()
		awful.spawn("mousepad")
	end, { description = "mousepad", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "n", function()
		awful.spawn("qutebrowser")
	end, { description = "qutebrowser", group = "launcher" }),
	awful.key({ superkey }, "n", function()
		awful.spawn("librewolf")
	end, { description = "librewolf", group = "launcher" }),
	awful.key({ superkey }, "b", function()
		awful.spawn(
			"brave-browser --force-device-scale-factor=1.2 --enable-features=AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL --disable-features=UseChromeOSDirectVideoDecoder,UseSkiaRenderer"
		)
	end, { description = "brave incognito", group = "launcher" }),
	awful.key({ superkey, "Shift" }, "w", function()
		awful.spawn("zen-browser")
	end, { description = "zen-browser", group = "launcher" }),
	awful.key({ superkey }, "w", function()
		awful.spawn("zen-twilight")
	end, { description = "zen-twilight", group = "launcher" }),
	awful.key({ superkey }, "y", function()
		awful.spawn.with_shell(
			'export PATH="$HOME/.local/bin:$PATH"; dash ~/Programs/shell/urlinmpv.sh >/dev/null 2>&1'
		)
	end, {
		description = "Play URL in mpv",
		group = "launcher",
	}),
	-- awful.key({ superkey }, "Escape", function()
	-- 	local s = mouse.screen
	-- 	s.mywibox.visible = not s.mywibox.visible
	-- end, { description = "toggle wibar visibility", group = "awesome" })
	awful.key({ superkey }, "Escape", function()
		local s = mouse.screen
		s.mywibox.visible = not s.mywibox.visible
		s.mywibox.ontop = s.mywibox.visible -- Only on top while shown
	end, { description = "toggle wibar visibility", group = "awesome" })
)

local clientkeys = gears.table.join(
	awful.key({ superkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ superkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ superkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ superkey, "Control" }, "apostrophe", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ superkey }, "apostrophe", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),

	-- awful.key({ superkey }, "t", function(c)
	-- 	c.ontop = not c.ontop
	-- end, { description = "toggle keep on top", group = "client" }),

	awful.key({ superkey }, "minus", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ superkey }, "period", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ superkey, "Control" }, "period", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ superkey, "Shift" }, "period", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" }),
	awful.key({ superkey, "Shift" }, "backslash", function(c)
		awful.titlebar.toggle(c)
	end, { description = "toggle titlebar", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ superkey }, "#" .. i + 9, function()
			local focused_screen = awful.screen.focused()
			local tag = focused_screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ superkey, "Control" }, "#" .. i + 9, function()
			local focused_screen = awful.screen.focused()
			local tag = focused_screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ superkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ superkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ superkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ superkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				-- M. rules
				"mpv",
				"vlc",
				"pavucontrol",
				"R_x11", -- R language graph pop-up
				"Pcmanfm",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = {
			floating = true,
		},
	},
	-- Titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

	-- M. rules
	{
		rule = { class = "Xfce4-terminal" },
		properties = { floating = true, placement = awful.placement.no_overlap },
	},

	{ rule = { class = "Mousepad" }, properties = { floating = true, placement = awful.placement.centered } },
	{ rule = { class = "Zathura" }, properties = { maximized = true } },
	{ rule = { class = "Alacritty" }, properties = { floating = true, maximized = true } },
	{ rule = { class = "libreoffice" }, properties = { floating = true, maximized = true } },
	{
		rule_any = {
			name = { "File Operation Progress", "Copying files", "Confirm" },
			-- class = { "Thunar", "thunar" },
		},
		properties = {
			floating = true,
			placement = awful.placement.centered,
			ontop = true,
			titlebars_enabled = true,
		},
	},

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- Rounded windows --
local function set_shape(c)
	if c.fullscreen then
		-- Use a normal rectangle: no corner radius (fullscreen)
		c.shape = function(cr, w, h)
			gears.shape.rectangle(cr, w, h)
		end
	else
		-- Use rounded rectangle for everything else (Normal windows)
		c.shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, 1) -- increase the number to get more rounded effect
		end
	end
end
client.connect_signal("manage", set_shape)
client.connect_signal("property::fullscreen", set_shape)
-- Signals }}}

-- M. Autostart apps
awful.spawn.with_shell("dash ~/.config/awesome/autostart.sh")
awful.spawn.with_shell('xinput set-prop "Elan Touchpad" "libinput Tapping Enabled" 1')
awful.spawn.with_shell('xinput set-prop "Elan Touchpad" "libinput Accel Speed" 0.5')
awful.spawn.with_shell('xinput set-prop "ELAN Touchscreen" "Device Enabled" 0')
awful.spawn.with_shell("xset -b")
awful.spawn.with_shell("dash ~/Programs/shell/capslock_withlock.sh")
