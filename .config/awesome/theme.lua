----------------------------------
---Tailor made theme for awesome
----------------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()
local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font                     = "FiraCode Nerd Font Bold 9"
theme.tooltip_font             = "FiraCode Nerd Font Bold 11"
theme.menu_font                = "FiraCode Nerd Font Ret 11"
theme.hotkeys_font             = "FiraCode Nerd Font Medium 11"
theme.hotkeys_description_font = "FiraCode Nerd Font Medium 11"

theme.bg_normal     = xrdb.background
theme.bg_focus      = xrdb.color12
theme.bg_urgent     = xrdb.color9
theme.bg_minimize   = xrdb.color8
theme.bg_systray    = xrdb.background

theme.fg_normal     = xrdb.foreground
theme.fg_focus      = xrdb.foreground
theme.fg_urgent     = xrdb.background
theme.fg_minimize   = xrdb.background

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(2)
theme.border_normal = xrdb.color0
theme.border_focus  = "#7F00FF"
theme.border_marked = xrdb.color10

theme.tooltip_fg = theme.fg_normal
theme.tooltip_bg = theme.bg_normal

theme.hotkeys_bg           = xrdb.background
theme.hotkeys_fg           = xrdb.foreground
theme.hotkeys_border_width = dpi(2)
theme.hotkeys_border_color = xrdb.color12       -- blue, for accent
theme.hotkeys_modifiers_fg = xrdb.color2        -- yellow/gold, or any prefered
theme.hotkeys_label_bg     = xrdb.color4        -- blue
theme.hotkeys_label_fg     = xrdb.background
theme.hotkeys_shape        = gears.shape.rounded_rect        -- rounded rectangle for style
theme.hotkeys_group_margin = 5


-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Define the rightclick menu
-- theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(16)
theme.menu_width  = dpi(133)


-- Define the image to load
theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"
-- theme.wallpaper = themes_path.."default/background.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Generate wallpaper:
local bg_numberic_value = 0;
for s in theme.bg_normal:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
    bg_numberic_value = bg_numberic_value + tonumber("0x"..s);
end
local is_dark_bg = (bg_numberic_value < 383)
local wallpaper_bg = xrdb.color0
local wallpaper_fg = xrdb.color6
local wallpaper_alt_fg = xrdb.color12
if not is_dark_bg then
    wallpaper_bg, wallpaper_fg = wallpaper_fg, wallpaper_bg
    end
    theme.wallpaper = function(s)
        return theme_assets.wallpaper(wallpaper_bg, wallpaper_fg, wallpaper_alt_fg, s)
        end

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
-- theme.icon_theme = "/usr/share/icons/Mint-Y-Purple/index.theme"

return theme

-- Reference for some more theme variables --
--
-- There are other variable sets overriding the default one when defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"
--
-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
--
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
-- You can add as many variables as you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"
--
-- Recolor Layout icons:
--theme = theme_assets.recolor_layout(theme, theme.fg_normal)
--
-- Recolor titlebar icons:
--local function darker(color_value, darker_n)
--    local result = "#"
--    for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
--        local bg_numeric_value = tonumber("0x"..s) - darker_n
--        if bg_numeric_value < 0 then bg_numeric_value = 0 end
--        if bg_numeric_value > 255 then bg_numeric_value = 255 end
--        result = result .. string.format("%2.2x", bg_numeric_value)
--    end
--    return result
--end
--theme = theme_assets.recolor_titlebar(
--    theme, theme.fg_normal, "normal"
--)
--theme = theme_assets.recolor_titlebar(
--    theme, darker(theme.fg_normal, -60), "normal", "hover"
--)
--theme = theme_assets.recolor_titlebar(
--    theme, xrdb.color1, "normal", "press"
--)
--theme = theme_assets.recolor_titlebar(
--    theme, theme.fg_focus, "focus"
--)
--theme = theme_assets.recolor_titlebar(
--    theme, darker(theme.fg_focus, -60), "focus", "hover"
--)
--theme = theme_assets.recolor_titlebar(
--    theme, xrdb.color1, "focus", "press"
--)
--
-- -- You can use your own layout icons like this:
-- theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
-- theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
-- theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
-- theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
-- theme.layout_max = themes_path.."default/layouts/maxw.png"
-- theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
-- theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
-- theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
-- theme.layout_tile = themes_path.."default/layouts/tilew.png"
-- theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
-- theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
-- theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
-- theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
-- theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
-- theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
-- theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"
--
--
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

