# shellcheck disable=SC2155
# If not running interactively don't do anything
[[ $- != *i* ]] && return

# Aliases
[ -f "$HOME/.aliasrc" ] && . "$HOME/.aliasrc"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Bash but like zsh like completions
[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
bind 'set colored-stats On'
bind 'set colored-completion-prefix On'
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set completion-query-items 50'
bind 'set show-all-if-ambiguous on'
bind '"\es": complete'
bind '"\t": menu-complete'
bind '"\e[Z": menu-complete-backward'
bind 'set page-completions off'
bind 'set menu-complete-display-prefix on'

# Flags for the bash
# Avoid duplicates in history
export HISTCONTROL=erasedups:ignoreboth
shopt -s histappend
shopt -s cmdhist
shopt -s lithist
export PROMPT_COMMAND="history -n; history -a"
export HISTIGNORE="ls:cd:pwd:exit:clear:history"

# Add fzf support --> CTRL-t = fzf select CTRL-r = fzf history ALT-c  = fzf cd
export FZF_DEFAULT_OPTS=" --bind='alt-p:toggle-preview' --preview='bat -p --color=always {}'"
eval "$(fzf --bash)"
# Fzf ctrl + r show no preview
export FZF_CTRL_R_OPTS="--no-preview --reverse"
export FZF_ALT_C_OPTS="--preview 'eza --color=always --icons -T {}' --reverse"
export FZF_CTRL_T_OPTS="--no-preview --reverse"

# add zoxide support
eval "$(zoxide init --cmd cd bash)"

# Colored manpager
export LESS_TERMCAP_mb=$(
  tput bold
  tput setaf 1
) # Red - blinking
export LESS_TERMCAP_md=$(
  tput bold
  tput setaf 2
)                                   # Green - bold headers
export LESS_TERMCAP_se=$(tput sgr0) # End standout
export LESS_TERMCAP_us=$(
  tput smul
  tput setaf 4
)                                   # Blue - underline
export LESS_TERMCAP_ue=$(tput sgr0) # End underline
export LESS_TERMCAP_me=$(tput sgr0) # End all modes
export LESS_TERMCAP_so=$(
  tput setab 3
  tput setaf 0
) # Highlighting foralternative-->(6,0)
# Use MANROFFOPT for compatibility
export MANROFFOPT="-c"

# Manual prompt Bash start
RED='\[\033[0;31m\]'
ORANGE='\[\033[38;5;208m\]'
GREEN='\[\033[0;32m\]'
MAGENTA='\[\033[0;35m\]'
YELLOW='\[\033[0;33m\]'
CYAN='\[\033[0;36m\]'
BOLD='\[\033[1m\]'
RESET='\[\033[0m\]'
export VIRTUAL_ENV_DISABLE_PROMPT=1
parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null && echo -n " $(git rev-parse --abbrev-ref HEAD 2>/dev/null)  " || true
}
parse_venv() {
  [ -n "$VIRTUAL_ENV" ] && echo -n " ($(basename "$VIRTUAL_ENV"))"
}
PS1="\n${YELLOW}  ${RESET}${MAGENTA}${BOLD} \w ${RESET}\$([ \$? -eq 0 ] && echo -e '${GREEN}🗸${RESET}' || echo -e '${RED}✘ ${RESET}')${ORANGE}${BOLD}\$(parse_git_branch)\$(parse_venv)${RESET} ${CYAN}${RESET} "
# Manual prompt Bash End

