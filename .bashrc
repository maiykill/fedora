# shellcheck disable=SC2155
# If not running interactively don't do anything
[[ $- != *i* ]] && return

# bin folders
[ -d "$HOME/.bin" ] && PATH="$HOME/.bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.local/ruby/gems/bin" ] && PATH="$HOME/.local/ruby/gems/bin:$PATH"
[ -d "$HOME/.local/rust/cargo/bin" ] && PATH="$HOME/.local/rust/cargo/bin:$PATH"

export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Golang specifics
export GOPATH=$HOME/.local/go

# Bash but like zsh
if [ -t 1 ]; then
  bind 'set colored-stats On'
  bind 'set colored-completion-prefix On'
  bind 'set show-all-if-ambiguous on'
  bind 'set completion-ignore-case on'
  bind 'set completion-query-items 100'
fi

# Flags for the bash
# Avoid duplicates in history
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
# export PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

# add fzf support
export FZF_DEFAULT_OPTS=" --bind='alt-p:toggle-preview' --preview='bat -p --color=always {}'"
eval "$(fzf --bash)"

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
GREEN='\[\033[0;32m\]'
MAGENTA='\[\033[0;35m\]'
YELLOW='\[\033[0;33m\]'
CYAN='\[\033[0;36m\]'
BOLD='\[\033[1m\]'
RESET='\[\033[0m\]'
exit_statuses() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}🗸${RESET}"
  else
    echo -e "${RED}✘ ${RESET}"
  fi
}
# PS1="${BOLD}${CYAN}\n${YELLOW}  ${RESET}${BOLD}${MAGENTA} \w ${CYAN}${RESET} ${BOLD}"
PS1="\n${BOLD}${YELLOW}  ${RESET}${BOLD}${MAGENTA} \w ${RESET}\$([ \$? -eq 0 ] && echo -e '${GREEN}🗸${RESET}' || echo -e '${RED}✘ ${RESET}') ${CYAN}${RESET} "
# Manual prompt Bash End


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
alias ls="ls --color=auto"
alias ll="eza --icons --time-style=long-iso --long"
alias lt="eza --icons --time-style=long-iso --tree"
alias la="eza --icons --time-style=long-iso --all"
alias lla="eza --icons --time-style=long-iso --long --all"
alias curip='curl --silent --location https://am.i.mullvad.net/json | gojq'
alias cpufetch='cpufetch --logo-intel-new'

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
