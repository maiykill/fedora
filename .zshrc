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

# old # ## prompt ZSH start
# old # # autoload -Uz promptinit && promptinit
# old # # prompt adam2
# old # ## OR
# old # ## Initialize Zsh modules FIRST for the prompt
# old # autoload -Uz vcs_info
# old # autoload -Uz colors && colors
# old # setopt PROMPT_SUBST
# old # # Git Configuration
# old # zstyle ':vcs_info:*' enable git
# old # zstyle ':vcs_info:git:*' formats ' %b'
# old # zstyle ':vcs_info:git:*' actionformats ' %b|%a'
# old # # Command Execution Time Tracking (No Italics)
# old # typeset -g CMD_START_TIME=0
# old # typeset -g CMD_TIME=""
# old # # Old time with only minutes and seconds
# old # # format_time() {
# old # #   local total_seconds=$1
# old # #   if ((total_seconds >= 60)); then
# old # #     printf "%dm%ds" $((total_seconds / 60)) $((total_seconds % 60))
# old # #   else
# old # #     printf "%ds" $total_seconds
# old # #   fi
# old # # }
# old # format_time() {
# old #   local total_seconds=$1
# old #   if ((total_seconds >= 3600)); then
# old #     local hours=$((total_seconds / 3600))
# old #     local remaining_seconds=$((total_seconds % 3600))
# old #     local minutes=$((remaining_seconds / 60))
# old #     local seconds=$((remaining_seconds % 60))
# old #     printf "%dh%dm%ds" $hours $minutes $seconds
# old #   elif ((total_seconds >= 60)); then
# old #     printf "%dm%ds" $((total_seconds / 60)) $((total_seconds % 60))
# old #   else
# old #     printf "%ds" $total_seconds
# old #   fi
# old # }
# old # preexec() { CMD_START_TIME=$SECONDS }
# old # precmd() {
# old #   vcs_info  # Git info
# old #   # Calculate command execution time
# old #   if (( CMD_START_TIME > 0 )); then
# old #     local elapsed=$((SECONDS - CMD_START_TIME))
# old #     if ((elapsed >= 1)); then
# old #       CMD_TIME="%B%F{cyan} $(format_time $elapsed)%f%b"  # Bold cyan, no italic
# old #     else
# old #       CMD_TIME=""
# old #     fi
# old #     CMD_START_TIME=0
# old #   else
# old #     CMD_TIME=""
# old #   fi
# old #   # Virtual Environment Prompt
# old #   VENV_PROMPT=""
# old #   if [[ -n "$VIRTUAL_ENV" ]]; then
# old #     VENV_PROMPT="%F{red}(%f%F{yellow}venv%F{red})%f "
# old #   fi
# old # }
# old # # PROMPT Definition (Simplified and Robust)
# old # PROMPT='%B%F{magenta}[%~]%f ${VENV_PROMPT}%F{green}${vcs_info_msg_0_}%f %(?.%F{green}🗸.%F{red}✘)%f${CMD_TIME} %F{yellow}%f%b '
# old # #The prompt is like below
# old # # (python) [~/Programs/python] (venv)  main 🗸 1s 
# old # ## prompt ZSH end


# Old2 ## -*- mode: zsh -*-
# Old2 ## PROMPT Configuration (Optimized)
# Old2 ## --------------------------------
# Old2 #
# Old2 ## Load colors once at startup
# Old2 #autoload -Uz colors && colors
# Old2 #
# Old2 ## Faster Git prompt
# Old2 #async_git_info() {
# Old2 #    ref=$(git branch --show-current 2>/dev/null) || return
# Old2 #    [ -n "$ref" ] && echo " $ref"
# Old2 #}
# Old2 #
# Old2 ## Time formatting with hours support
# Old2 #format_time() {
# Old2 #    local t=$1
# Old2 #    (( t >= 3600 )) && printf "%dh%dm%ds" $((t/3600)) $((t%3600/60)) $((t%60)) && return
# Old2 #    (( t >= 60 )) && printf "%dm%ds" $((t/60)) $((t%60)) && return
# Old2 #    printf "%ds" $t
# Old2 #}
# Old2 #
# Old2 ## Timing variables
# Old2 #typeset -g cmd_start=0
# Old2 #
# Old2 ## Track command start time
# Old2 #preexec() { cmd_start=$SECONDS }
# Old2 #
# Old2 ## Build prompt
# Old2 #precmd() {
# Old2 #    local exit_status=$?
# Old2 #    local git_prompt=$(async_git_info)
# Old2 #    local cmd_time=""
# Old2 #
# Old2 #    if (( cmd_start > 0 )); then
# Old2 #        local duration=$((SECONDS - cmd_start))
# Old2 #        if (( duration >= 1 )); then
# Old2 #            cmd_time="%B%F{cyan} $(format_time $duration)%f%b"
# Old2 #        fi
# Old2 #        cmd_start=0  # Reset after calculation
# Old2 #    fi
# Old2 #
# Old2 #    local venv_prompt=""
# Old2 #    [[ -n "$VIRTUAL_ENV" ]] && venv_prompt="%F{red}(%F{yellow}venv%F{red})%f "
# Old2 #
# Old2 #    PROMPT="%B%F{magenta}[%~]%f ${venv_prompt}%F{green}${git_prompt}%f "
# Old2 #    PROMPT+="%(?.%F{green}🗸.%F{red}✘)%f${cmd_time} %F{yellow}%f%b "
# Old2 #}
# Old2 #
# Old2 ## Initial prompt
# Old2 #PROMPT='%B%F{magenta}[%~]%f %F{yellow}%f%b '














# -*- mode: zsh -*-
# Corrected Enhanced PROMPT Configuration
# ---------------------------------------

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
    git_cache=" ${ref}${dirty}${remote_status}"
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

# Random color header
colors=(red green yellow blue magenta cyan)
random_color() {
    echo "${colors[$RANDOM % 6 + 1]}"
}

# Build prompt
precmd() {
    local exit_status=$?
    local git_prompt=$(async_git_info)
    local cmd_time=""

    # Command timing
    if (( cmd_start > 0 )); then
        local duration=$((SECONDS - cmd_start))
        if (( duration >= 1 )); then
            cmd_time="%B%F{cyan} $(format_time $duration)%f%b"
        fi
        cmd_start=0
    fi

    # Virtual environment
    local venv_prompt=""
    [[ -n "$VIRTUAL_ENV" ]] && venv_prompt="%F{red}(%F{yellow}venv%F{red})%f "

    # Random color header
    local header_color="%F{$(random_color)}"

    # Construct prompt
    PROMPT="${header_color}╭─%f %B%F{magenta}[%~]%f "
    PROMPT+="${venv_prompt}"
    PROMPT+="%F{green}${git_prompt}%f "
    PROMPT+="%(?.%F{green}🗸.%F{red}✘ %F{white}%? )%f${cmd_time}"
    PROMPT+=$'\n'"${header_color}╰─%f %F{yellow}%f%b "
}

# Initial prompt
PROMPT='%F{cyan}╭─%f%B%F{magenta}[%~]%f %F{yellow}%f%b\n%F{cyan}╰─%f '















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


