## I created this file for setting Environment variables with ZSHELL
#NOTE: 
#1. for some reason cursor files in 
#   ~/.local/share/icons are not recognised unless exported
#   leading to cursor theme not applying in qt based applications like qbittorrent and qutebrowser.

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
