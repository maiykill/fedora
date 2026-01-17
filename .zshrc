# vim: set filetype=zsh :

# zsh
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Aliases
[ -f "$HOME/.aliasrc" ] && . "$HOME/.aliasrc"

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
    # # Double line prompt Start
    # PROMPT="%F{green}╭─%f %B%F{magenta}[%~]%f ${venv_prompt}%F{green}${git_prompt}%f %(?.%F{green}🗸.%F{red}✘ %F{red}%?)%f${cmd_time}"$'\n'"%F{green}╰─%f %F{yellow}%f%b "
    # # Double line prpmpt End
    # Single line prompt Start
    local right_prompt="%B%F{green} %f%b %(?.%B%F{green}🗸%b%f.%B%F{red}✘ %?)${cmd_time}%b%f %B%F{blue}${git_prompt}%b%f %B%F{yellow}%f%b"
    local left_prompt="%B%F{yellow}%f%b %B${venv_prompt}%B%F{magenta}(%~)%f %B%F{green} %f%b"
    PROMPT="${left_prompt} "
    RPROMPT="${right_prompt}" && print ""
    # Single line prompt End
    cmd_start=0
}
## Manual prompt ZSH end  ▶




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
source <(fzf --zsh)
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix'
export FZF_DEFAULT_OPTS=" --bind='alt-p:change-preview-window(down|hidden|)' --preview='bat -n -p --color=always {}'"
export FZF_CTRL_R_OPTS="--no-preview --reverse --header ' [ History Search --> ] ' --color 'header:bold:cyan'"
export FZF_ALT_C_OPTS="--preview 'eza --color=always --icons -T {}' --reverse --header ' [ Cd to -->] ' --color 'header:bold:cyan'"
# export FZF_CTRL_T_OPTS=" --no-preview --reverse --header ' [ Get filename --> (C-h for home) ] ' --color 'header:bold:cyan' --bind 'ctrl-h:reload(fd --hidden --search-path $HOME)'"


## Zellij
# eval "$(zellij setup --generate-auto-start zsh)"


###############################################################################################################################################
##############################################################################################################################################








