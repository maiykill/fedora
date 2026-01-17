#NOTE: 
#1. for some reason cursor files in 
#   ~/.local/share/icons are not recognised unless exported
#   leading to cursor theme not applying in qt based applications like qbittorrent and qutebrowser.

# bin folders
[ -d "$HOME/.bin" ] && PATH="$HOME/.bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.local/ruby/gems/bin" ] && PATH="$HOME/.local/ruby/gems/bin:$PATH"
[ -d "$HOME/.local/rust/cargo/bin" ] && PATH="$HOME/.local/rust/cargo/bin:$PATH"


# User specific environment and startup programs
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export EDITOR="/usr/bin/nvim"
export LIBVA_DRIVER_NAME="iHD"
export TERMINAL='/usr/bin/alacritty'
export XCURSOR_PATH=${XCURSOR_PATH}:~/.local/share/icons
export GOPATH=$HOME/.local/go
export GEM_PATH=$HOME/.local/ruby/gems
export GEM_SPEC_CACHE=$HOME/.local/ruby/specs
export GEM_HOME=$HOME/.local/ruby/gems
export QT_SCALE_FACTOR=1.25
export CARGO_HOME="$HOME"/.local/rust/cargo
export MOZ_USE_XINPUT2=1

