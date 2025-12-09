# config.py
# flake8: noqa: F821

# Load existing settings
config.load_autoconfig()  # noqa: F821

# Enable forced dark mode on all webpages
c.colors.webpage.darkmode.enabled = True  # noqa: F821


# Unbind both keys first to avoid duplicate bindings
config.unbind('q')
config.unbind('f')

# Bind 'q' to the default action of 'f' (follow hint)
config.bind('q', 'hint')


