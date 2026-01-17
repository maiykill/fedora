# .bash_profile

# Bin folders
[ -d "$HOME/.bin" ] && PATH="$HOME/.bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.local/ruby/gems/bin" ] && PATH="$HOME/.local/ruby/gems/bin:$PATH"
[ -d "$HOME/.local/rust/cargo/bin" ] && PATH="$HOME/.local/rust/cargo/bin:$PATH"
export PATH

# User specific environment and startup programs
export EDITOR="/usr/bin/nvim"
export TERMINAL='/usr/bin/alacritty'
export LIBVA_DRIVER_NAME=iHD
export QT_SCALE_FACTOR=1.25
export XCURSOR_PATH=${XCURSOR_PATH}:~/.local/share/icons
export GOPATH=$HOME/.local/go
export GEM_PATH=$HOME/.local/ruby/gems
export GEM_SPEC_CACHE=$HOME/.local/ruby/specs
export GEM_HOME=$HOME/.local/ruby/gems
export CARGO_HOME="$HOME"/.local/rust/cargo

# Other XDG paths
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}

# Get the aliases and functions
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
