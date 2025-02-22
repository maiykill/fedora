# zsh
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Auto suggestion and Syntax highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt share_history

# Command completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# prompt ZSH
autoload -Uz promptinit && promptinit
prompt adam2

## Changing the syntax colour to blue from the default green i guess!
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan,bold


# Golang specifics
export GOPATH=$HOME/.local/go

# Zoxide Command
eval "$(zoxide init --cmd cd zsh)"

# XDG_RUNTIME_DIR for mpv hardware acceleration
 if [ -z "$XDG_RUNTIME_DIR" ]; then
     export XDG_RUNTIME_DIR=/tmp
     if [ ! -d  "$XDG_RUNTIME_DIR" ]; then
         mkdir "$XDG_RUNTIME_DIR"
         chmod 0700 "$XDG_RUNTIME_DIR"
     fi
 fi


#NOTE: Experimental features on 2025-01-24 19:57
# stop the ctrl+s freeze.
stty stop undef
# colors
autoload -Uz colors && colors




###############################################################################################################################################
##############################################################################################################################################

## Custom SCRIPTS

# bin folders
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.bin" ] ; then
    PATH="$HOME/.bin:$PATH"
fi

## Zellij
# eval "$(zellij setup --generate-auto-start zsh)"


###############################################################################################################################################
##############################################################################################################################################

# Custom FUNCTIONS

ext ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

dotter ()
{
  ln -f ~/.bash_profile ~/Programs/fedora/.bash_profile
  ln -f ~/.bashrc ~/Programs/fedora/.bashrc
  ln -f ~/.vimrc ~/Programs/fedora/.vimrc
  ln -f ~/.zshenv ~/Programs/fedora/.zshenv
  ln -f ~/.zshrc ~/Programs/fedora/.zshrc
  ln -f ~/.config/mimeapps.list ~/Programs/fedora/.config/mimeapps.list
  ln -f ~/.config/alacritty/alacritty.toml ~/Programs/fedora/.config/alacritty
  ln -f ~/.config/btop/themes/rose-pine.theme ~/Programs/fedora/.config/btop/themes/rose-pine.theme
  ln -f ~/.config/ghostty/config ~/Programs/fedora/.config/ghostty/config
  ln -f ~/.config/helix/config.toml ~/Programs/fedora/.config/helix/config.toml
  ln -f ~/.config/helix/languages.toml ~/Programs/fedora/.config/helix/languages.toml
  ln -f ~/.config/kitty/kitty.conf ~/Programs/fedora/.config/kitty/kitty.conf
  ln -f ~/.config/kitty/current-theme.conf ~/Programs/fedora/.config/kitty/current-theme.conf
  ln -f ~/.config/lf/colors ~/Programs/fedora/.config/lf/colors
  ln -f ~/.config/lf/icons ~/Programs/fedora/.config/lf/icons
  ln -f ~/.config/lf/lfrc ~/Programs/fedora/.config/lf/lfrc
  ln -f ~/.config/lf/previewer ~/Programs/fedora/.config/lf/previewer
  ln -f ~/.config/mpv/mpv.conf ~/Programs/fedora/.config/mpv/mpv.conf
  ln -f ~/.config/mpv/input.conf ~/Programs/fedora/.config/mpv/input.conf
  ln -f ~/.config/nvim/lua/config/keymaps.lua ~/Programs/fedora/.config/nvim/lua/config/keymaps.lua
  ln -f ~/.config/nvim/lua/config/options.lua ~/Programs/fedora/.config/nvim/lua/config/options.lua
  ln -f ~/.config/nvim/lua/plugins/nvim-lspconfig.lua ~/Programs/fedora/.config/nvim/lua/plugins/nvim-lspconfig.lua
  ln -f ~/.config/nvim/lua/plugins/telescope.lua ~/Programs/fedora/.config/nvim/lua/plugins/telescope.lua
  ln -f ~/.config/nvim/lua/plugins/fzf.lua ~/Programs/fedora/.config/nvim/lua/plugins/fzf.lua
  ln -f ~/.config/nvim/lua/plugins/snacks.lua ~/Programs/fedora/.config/nvim/lua/plugins/snacks.lua
  ln -f ~/.config/qBittorrent/main.qbtheme ~/Programs/fedora/.config/qBittorrent/main.qbtheme
  ln -f ~/.config/wezterm/wezterm.lua ~/Programs/fedora/.config/wezterm/wezterm.lua
  ln -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ~/Programs/fedora/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
  ln -f ~/.config/zathura/zathurarc ~/Programs/fedora/.config/zathura/zathurarc
}

###############################################################################################################################################

# ALIASES

alias psmem='ps auxf | sort -nr -k 4 | head -5'
alias pscpu='ps auxf | sort -nr -k 3 | head -5'
alias ls='ls --color=auto'
alias df='df -Th'
alias free='free -m'
alias grep='grep --color=auto'
alias free="free -mth"
alias probe="sudo -E hw-probe -all -upload"
alias m3="mpv '--ytdl-format=bestvideo[height=360]+worstaudio'"
alias m4="mpv '--ytdl-format=bestvideo[height=480]+worstaudio'"
alias m7="mpv '--ytdl-format=bestvideo[height=720]+worstaudio'"
alias m10="mpv '--ytdl-format=bestvideo[height=1080]+worstaudio'"
alias pdf="soffice --headless --convert-to pdf"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias timec="sudo ntpd -qg; sudo hwclock --systohc"
alias update-fc='sudo fc-cache -fv'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias jctl='journalctl -p 3 -xb'
alias wget='wget -c'
alias xb='vim ~/.bashrc'
alias xz="vim /home/mike/.zshrc"
alias xl='vim /home/mike/.config/lf/lfrc'
alias xx='vim ~/.Xresources'
alias xa='vim ~/.config/alacritty/alacritty.toml'
alias xm='vim ~/.config/mpv/mpv.conf'
alias xp='vim ~/.config/polybar/config'
alias xv='vim ~/.vimrc'
alias xq="vim ~/.config/qtile/config.py"
alias ymp3='yt-dlp --extract-audio --audio-format mp3 '
alias merge='xrdb -merge ~/.Xresources'
alias backup='rsync -av /home/mike/.bashrc /home/mike/.zshrc /home/mike/.zshrc-personal /home/mike/.local/share/fonts /home/mike/.bashrc-personal /home/mike/.vimrc /home/mike/.Xresources /home/mike/.vim /home/mike/.config/i3 /home/mike/.config/wm-wallpapers /home/mike/.config/awesome /home/mike/.config/polybar /home/mike/.config/ranger /home/mike/Public/dot-files/arco-linux/backup-config/'
alias vim='nvim'
alias p="python"
alias ffmpeg="ffmpeg -hide_banner"
alias ffprobe="ffprobe -hide_banner"
alias ls="eza"

###############################################################################################################################################
##############################################################################################################################################


