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
setopt correct

# Command completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'


## Manual prompt ZSH start
# Load colors once at startup
autoload -Uz colors && colors
# Git prompt with caching and remote tracking
typeset -g last_git_check=0 git_cache=""
async_git_info() {
    # Check cache (5 second TTL)
    if (( $(date +%s) < last_git_check + 5 )) && [[ -n "$git_cache" ]]; then
        echo "$git_cache"
        return
    fi
    # Get Git info
    ref=$(git branch --show-current 2>/dev/null) || return
    [ -z "$ref" ] && return
    # Dirty state
    dirty=""
    [ -n "$(git status -s 2>/dev/null)" ] && dirty=" ±"
    # Remote tracking
    local ahead=0 behind=0
    git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | IFS=$'\t' read behind ahead
    remote_status=""
    (( behind > 0 )) && remote_status+=" ↓$behind"
    (( ahead > 0 )) && remote_status+=" ↑$ahead"
    # Build cache
    git_cache=" ${ref}${dirty}${remote_status}" # alternative icon 
    last_git_check=$(date +%s)
    echo "$git_cache"
}
# Time formatting with hours support
format_time() {
    local t=$1
    (( t >= 3600 )) && printf "%dh%dm%ds" $((t/3600)) $((t%3600/60)) $((t%60)) && return
    (( t >= 60 )) && printf "%dm%ds" $((t/60)) $((t%60)) && return
    printf "%ds" $t
}
# Timing variables
typeset -g cmd_start=0
# Track command start time
preexec() { cmd_start=$SECONDS }
# Build prompt 
precmd() {
    local exit_status=$? git_prompt=$(async_git_info) cmd_time="" duration=0 venv_prompt=""
    (( cmd_start > 0 )) && (( duration = SECONDS - cmd_start )) && (( duration >= 1 )) && cmd_time="%B%F{cyan} $(format_time $duration)%f%b"
    [[ -n "$VIRTUAL_ENV" ]] && venv_prompt="%F{red}(%F{yellow}${VIRTUAL_ENV##*/}%F{red})%f "
    # # Double line prompt
    # PROMPT="%F{green}╭─%f %B%F{magenta}[%~]%f ${venv_prompt}%F{green}${git_prompt}%f %(?.%F{green}🗸.%F{red}✘ %F{red}%?)%f${cmd_time}"$'\n'"%F{green}╰─%f %F{yellow}%f%b "
    # Single line prompt
    PROMPT="%B%F{green} %f%b %B%F{magenta}(%~)%f ${venv_prompt}%F{green}${git_prompt}%f %(?.%F{green}🗸.%F{red}✘ %F{red}%?)%f${cmd_time}"$''"%F{green}%f %F{yellow}%f%b " && print ""
    cmd_start=0
}
## Manual prompt ZSH end ▶




## Changing the syntax colour to blue from the default green i guess!
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan,bold



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


# Classic colored man pages
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)      # Red - blinking
export LESS_TERMCAP_md=$(tput bold; tput setaf 2)      # Green - bold headers
export LESS_TERMCAP_se=$(tput sgr0)                    # End standout
export LESS_TERMCAP_us=$(tput smul; tput setaf 4)      # Blue - underline
export LESS_TERMCAP_ue=$(tput sgr0)                    # End underline
export LESS_TERMCAP_me=$(tput sgr0)                    # End all modes
export LESS_TERMCAP_so=$(tput setab 3; tput setaf 0)   # Highlighting foralternative-->(6,0)
# Use MANROFFOPT for compatibility
export MANROFFOPT="-c"


#NOTE: Experimental features on 2025-01-24 19:57
# stop the ctrl+s freeze.
stty stop undef


# FZF flags for previewing in the side
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix'
export FZF_DEFAULT_OPTS=" --bind='alt-p:toggle-preview' --preview='bat -p --color=always {}'"
source <(fzf --zsh)

###############################################################################################################################################
##############################################################################################################################################

## Custom SCRIPTS

# bin folders
[ -d "$HOME/.bin" ] && PATH="$HOME/.bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.local/ruby/gems/bin" ] && PATH="$HOME/.local/ruby/gems/bin:$PATH"


## Zellij
# eval "$(zellij setup --generate-auto-start zsh)"


###############################################################################################################################################
##############################################################################################################################################

# Custom FUNCTIONS

ext() {
  if [ -f "$1" ]; then
    case $1 in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *.deb) ar x "$1" ;;
    *.tar.xz) tar xf "$1" ;;
    *.tar.zst) unzstd "$1" ;;
    *) echo "${1} cannot be extracted via ex()" ;;
    esac
  else
    echo "${1} is not a valid file"
  fi
}

dotter() {
  ln -f ~/.bash_profile ~/Programs/fedora/.bash_profile
  ln -f ~/.bashrc ~/Programs/fedora/.bashrc
  ln -f ~/.vimrc ~/Programs/fedora/.vimrc
  ln -f ~/.zshenv ~/Programs/fedora/.zshenv
  ln -f ~/.zshrc ~/Programs/fedora/.zshrc
  ln -f ~/.Xresources ~/Programs/fedora/.Xresources
  ln -f ~/.config/gtk-3.0/settings.ini ~/Programs/fedora/.config/gtk-3.0/settings.ini
  ln -f ~/.config/mimeapps.list ~/Programs/fedora/.config/mimeapps.list
  ln -f ~/.config/alacritty/alacritty.toml ~/Programs/fedora/.config/alacritty
  ln -f ~/.config/btop/themes/rose-pine.theme ~/Programs/fedora/.config/btop/themes/rose-pine.theme
  ln -f ~/.config/ghostty/config ~/Programs/fedora/.config/ghostty/config
  ln -f ~/.config/dunst/dunstrc ~/Programs/fedora/.config/dunst/dunstrc
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
  ln -f ~/.config/mpv/scripts/accurate_slicer.lua ~/Programs/fedora/.config/mpv/scripts/accurate_slicer.lua
  ln -f ~/.config/mpv/scripts/slicer.lua ~/Programs/fedora/.config/mpv/scripts/slicer.lua
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
  rsync -a --delete ~/.config/awesome/ ~/Programs/fedora/.config/awesome/
  rsync -a --delete ~/.local/share/fonts/ ~/Programs/fedora/.local/share/fonts/
}

top5() {
  fd . "$1" -H --exact-depth 1 -0 | xargs -0 du -sh | sort -hr | head -5
}

###############################################################################################################################################

# ALIASES


# alias update-fc='sudo fc-cache -fv'
# alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
# alias timec="sudo ntpd -qg; sudo hwclock --systohc"
# alias xp='nvim ~/.config/polybar/config'
# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
alias psmem='ps auxf | sort --numeric-sort --reverse --key=4 | head -5 | bat --style=plain -l dml'
alias pscpu='ps auxf | sort --numeric-sort --reverse --key=3 | head -5 | bat --style=plain -l dml'
alias df='df --print-type --human-readable'
alias probe="sudo -E hw-probe -all -upload"
alias m3="mpv '--ytdl-format=bv*[height=360]+wa*'"
alias m4="mpv '--ytdl-format=bv*[height=480]+wa*'"
alias m7="mpv '--ytdl-format=bv*[height=720]+wa*'"
alias m10="mpv '--ytdl-format=bv*[height=1080]+wa*'"
alias myo="mpv '--ytdl-format=bv*[vcodec!*=av01]+ba'"
alias topdf="soffice --headless --convert-to pdf"
alias cp="cp --interactive --verbose"
alias mv="mv --interactive --verbose"
alias rm="rm --verbose"
alias jctl='journalctl --priority=3 --catalog --boot=0'
alias wget='wget --continue'
alias vimb='nvim ~/.bashrc'
alias vimz="nvim /home/mike/.zshrc"
alias viml='nvim /home/mike/.config/lf/lfrc'
alias vimx='nvim ~/.Xresources'
alias vimta='nvim ~/.config/alacritty/alacritty.toml'
alias vimtk='nvim ~/.config/kitty/kitty.conf'
alias vimtw='nvim ~/.config/wezterm/wezterm.lua'
alias vima='nvim ~/.config/awesome/rc.lua'
alias vimm='nvim ~/.config/mpv/mpv.conf'
alias vimv='nvim ~/.vimrc'
# alias vimq="nvim ~/.config/qtile/config.py"
alias ymp3='yt-dlp --extract-audio --audio-format mp3'
alias yopus='yt-dlp --extract-audio --audio-format opus'
alias merge='xrdb -merge ~/.Xresources'
alias p="python"
alias p2="pypy3"
alias ffmpeg="ffmpeg -hide_banner"
alias ffprobe="ffprobe -hide_banner"
alias rudo="sudo-rs"
alias ru="su-rs"
alias eza="eza --icons --time-style=long-iso"
alias historys="history 1 | fzf --preview='' --preview-window='hidden'"
alias ll="eza --icons --time-style=long-iso --long"
alias lt="eza --icons --time-style=long-iso --tree"
alias la="eza --icons --time-style=long-iso --all"
alias lla="eza --icons --time-style=long-iso --long --all"
alias curip='curl --silent --location https://am.i.mullvad.net/json | gojq'
alias cpufetch='cpufetch --logo-intel-new'



###############################################################################################################################################
##############################################################################################################################################
