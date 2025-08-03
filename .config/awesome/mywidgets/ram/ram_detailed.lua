
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

-- Theme colors table
local themecolors = {
    bg = "#232136",    -- dark background (Rose Pine)
    fg = "#e0def4",    -- light foreground (Rose Pine)
    used = "#f9e2af",  -- Catppuccin Mocha yellow
    cached = "#8bd5ca",-- Catppuccin Macchiato teal
    avail = "#50c878", -- Emerald Green
    swap = "#fe8019",  -- Gruvbox orange
    icon = "#2dece2",  -- Nord Green
}

-- Theme fonts table
local themefonts = {
    icon = "FiraCode Nerd Font Propo Bold 13",
    text = "FiraCode Nerd Font Propo Bold 13",
}

-- Theme icons table
local themeicons = {
    ram = "", -- the RAM icon glyph
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

local ram_text = wibox.widget({
    markup = string.format(
        '<span font="%s" color="%s">%s</span><span font="%s"><span color="%s">--%%(--)</span><span color="%s">--%%(--)</span><span color="%s">--%%(--)</span><span color="%s">--%%(--)</span></span>',
        themefonts.icon,
        themecolors.icon,
        themeicons.ram,
        themefonts.text,
        themecolors.used,
        themecolors.cached,
        themecolors.avail,
        themecolors.swap
    ),
    widget = wibox.widget.textbox,
})

local ram_widget = wibox.widget({
    {
        ram_text,
        layout = wibox.layout.fixed.horizontal,
    },
    bg = themecolors.bg,
    fg = themecolors.fg,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
    set_text = function(self, used_p, used, cached_p, cached, avail_p, avail, swap_p, swap)
        ram_text.markup = string.format(
            '<span font="%s" color="%s">%s</span><span font="%s"><span color="%s">%d(%s)</span><span color="%s">%d(%s)</span><span color="%s">%d(%s)</span><span color="%s">%d(%s)</span></span>',
            themefonts.icon,
            themecolors.icon,
            themeicons.ram,
            themefonts.text,
            themecolors.used,
            used_p,
            used,
            themecolors.cached,
            cached_p,
            cached,
            themecolors.avail,
            avail_p,
            avail,
            themecolors.swap,
            swap_p,
            swap
        )
    end,
})

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

