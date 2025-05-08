## I created this file for setting Environment variables with ZSHELL
#NOTE: 
#1. for some reason cursor files in 
#   ~/.local/share/icons are not recognised unless exported
#   leading to cursor theme not applying in qt based applications like qbittorrent and qutebrowser.

export EDITOR="/usr/bin/nvim"
export LIBVA_DRIVER_NAME="iHD"
export TERMINAL='/usr/bin/alacritty'
export XCURSOR_PATH=${XCURSOR_PATH}:~/.local/share/icons
