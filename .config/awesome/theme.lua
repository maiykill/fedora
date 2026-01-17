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
theme.alternatefont            = "Iosevka Term Extended 14"
theme.alternateboldfont        = "Iosevka Term Extended Bold 14"
theme.tooltip_font             = "FiraCode Nerd Font Bold 11"
theme.menu_font                = "FiraCode Nerd Font Ret 11"
theme.hotkeys_font             = "FiraCode Nerd Font Medium 11"
theme.hotkeys_description_font = "FiraCode Nerd Font Medium 11"

theme.bg_normal     = xrdb.background
theme.bg_focus      = xrdb.color12
theme.bg_urgent     = xrdb.color9
theme.bg_minimize   = xrdb.color8
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = xrdb.foreground
theme.fg_focus      = xrdb.foreground
theme.fg_urgent     = xrdb.background
theme.fg_minimize   = xrdb.background

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(0.7)
theme.border_normal = xrdb.color0
-- theme.border_focus  = "#7F00FF"
-- theme.border_focus  = "#AAFF00"
theme.border_focus  = "#C70B63"
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


-- Additional colorschemes
-- Catppuccin
theme.cat_rosewater = "#f5e0dc"
theme.cat_flamingo  = "#f2cdcd"
theme.cat_pink      = "#f5c2e7"
theme.cat_mauve     = "#cba6f7"
theme.cat_red       = "#f38ba8"
theme.cat_maroon    = "#eba0ac"
theme.cat_peach     = "#fab387"
theme.cat_yellow    = "#f9e2af"
theme.cat_green     = "#a6e3a1"
theme.cat_teal      = "#94e2d5"
theme.cat_sky       = "#89dceb"
theme.cat_blue      = "#89b4fa"
theme.cat_lavender  = "#b4befe"
theme.cat_text      = "#cdd6f4"
theme.cat_surface0  = "#313244"
-- Rosepine
theme.rose_base     = "#191724"
theme.rose_muted    = "#6e6a86"
theme.rose_subtle   = "#908caa"
theme.rose_text     = "#e0def4"
theme.rose_love     = "#eb6f92"
theme.rose_gold     = "#f6c177"
theme.rose_rose     = "#ebbcba"
theme.rose_pine     = "#31748f"
theme.rose_foam     = "#9ccfd8"
theme.rose_iris     = "#c4a7e7"
-- Kanagawa
theme.kana_sumiink     = "#16161D"
theme.kana_fujiwhite   = "#DCD7BA"
theme.kana_oldwhite    = "#C8C093"
theme.kana_autumnred   = "#C34043"
theme.kana_peachred    = "#FF5D62"
theme.kana_sakurapink  = "#D27E99"
theme.kana_lightblue   = "#7FB4CA"
theme.kana_dragonblue  = "#658594"
theme.kana_springgreen = "#98BB6C"
theme.kana_waveaqua    = "#7AA89F"
theme.kana_boatyellow  = "#E6C384"
theme.kana_carpyellow  = "#E6C384"
theme.kana_katanagray  = "#717C7C"
theme.kana_bamboogreen = "#76946A"
theme.kana_crystalblue = "#7E9CD8"
theme.kana_samuraired  = "#E82424"
-- Nord 
theme.nord_polarnight  = "#2E3440"
theme.nord_snowstorm   = "#D8DEE9"
theme.nord_frost       = "#8FBCBB"
theme.nord_seaBlue     = "#81A1C1"
theme.nord_iceBlue     = "#88C0D0"
theme.nord_red         = "#BF616A"
theme.nord_orange      = "#D08770"
theme.nord_yellow      = "#EBCB8B"
theme.nord_green       = "#A3BE8C"
theme.nord_cyan        = "#8FBCBB"
theme.nord_purple      = "#B48EAD"
theme.nord_comment     = "#4C566A"
theme.nord_white       = "#ECEFF4"
theme.nord_gray        = "#434C5E"
-- NightOwl
theme.nightowl_bg       = "#011627"
theme.nightowl_fg       = "#d6deeb"
theme.nightowl_blue     = "#82aaff"
theme.nightowl_cyan     = "#7fdbca"
theme.nightowl_green    = "#22da6e"
theme.nightowl_yellow   = "#ffeb95"
theme.nightowl_orange   = "#f78c6c"
theme.nightowl_red      = "#ef5350"
theme.nightowl_pink     = "#c792ea"
theme.nightowl_purple   = "#a599e9"
theme.nightowl_gray     = "#5f7e97"
theme.nightowl_comment  = "#637777"
theme.nightowl_white    = "#ffffff"

-- Tokyonight
theme.tokyo_bg       = "#1a1b26"
theme.tokyo_fg       = "#c0caf5"
theme.tokyo_blue     = "#7aa2f7"
theme.tokyo_cyan     = "#7dcfff"
theme.tokyo_green    = "#9ece6a"
theme.tokyo_yellow   = "#e0af68"
theme.tokyo_orange   = "#ff9e64"
theme.tokyo_red      = "#f7768e"
theme.tokyo_magenta  = "#bb9af7"
theme.tokyo_purple   = "#9d7cd8"
theme.tokyo_comment  = "#565f89"
theme.tokyo_gray     = "#414868"
theme.tokyo_white    = "#c0caf5"




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

