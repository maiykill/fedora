# config.py
# flake8: noqa: F821

config.load_autoconfig()  # noqa: F821

# dark mode setup
c.colors.webpage.darkmode.enabled = True  # noqa: F821
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'never'
config.set('colors.webpage.darkmode.enabled', False, 'file://*')

################################################################################
# Pure black background for hints
c.colors.hints.bg = 'rgba(0, 0, 0, 0.6)'  # noqa: F821
c.colors.hints.fg = "#00ff00"  # noqa: F821
c.colors.hints.match.fg = "#00ff00"  # noqa: F821
# Add padding to make hints more readable on HiDPI (top, right, bottom, left)
# c.hints.padding = {"top": 4, "right": 6, "bottom": 4, "left": 6}  # noqa: F821
c.hints.border = "2px solid #000000"  # noqa: F821
c.colors.completion.even.bg = "#18191E" # noqa: F821
c.colors.completion.odd.bg = "#18191E" # noqa: F821
c.colors.completion.fg = "#44B273" # noqa: F821
c.colors.completion.category.bg = "#18191E" # noqa: F821
c.colors.completion.category.fg = "#2787c2" # noqa: F821
c.colors.completion.item.selected.bg = "#21252D" # noqa: F821
c.colors.completion.item.selected.fg = "#FFFF00" # noqa: F821
c.colors.completion.match.fg = "#d68eb2" # noqa: F821
c.colors.completion.item.selected.match.fg = "#d68eb2" # noqa: F821
c.colors.completion.scrollbar.bg = "#18191E" # noqa: F821
c.colors.completion.scrollbar.fg = "#44B273" # noqa: F821
c.colors.completion.category.border.top = "#21252D" # noqa: F821
c.colors.completion.category.border.bottom = "#21252D" # noqa: F821
c.colors.completion.item.selected.border.top = "#44B273" # noqa: F821
c.colors.completion.item.selected.border.bottom = "#44B273" # noqa: F821
c.colors.tabs.even.fg = "#ffffff"
c.colors.tabs.odd.fg =  "#ffffff"
c.colors.tabs.selected.even.bg = "#18191e"
c.colors.tabs.selected.odd.bg =  "#18191e"
c.colors.tabs.selected.even.fg = "#44b273"
c.colors.tabs.selected.odd.fg =  "#44b273"


################################################################################
# Completion Widget Font (Fira Sans)
################################################################################
c.fonts.completion.category = 'bold 12pt "Fira Sans"' # noqa: F821
c.fonts.completion.entry = '12pt "Fira Sans"' # noqa: F821
c.fonts.statusbar = '12pt "Fira Sans"'  # noqa: F821
c.fonts.hints = 'Bold 12pt "Fira Sans"'  # noqa: F821

################################################################################
# privacy - adjust these settings based on your preference
################################################################################
# config.set("completion.cmd_history_max_items", 0)
# config.set("content.private_browsing", True)
config.set("content.webgl", False, "*")
config.set("content.canvas_reading", False)
config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")
config.set("content.cookies.accept", "all")
config.set("content.cookies.store", True)
c.content.blocking.enabled = True
# config.set("content.javascript.enabled", False) # tsh keybind to toggle

################################################################################
# Key Bindings
################################################################################

# Unbind both keys first to avoid duplicate bindings
config.unbind("q")
config.unbind("f")

# Bind 'q' to the default action of 'f' (follow hint)
config.bind("q", "hint")

