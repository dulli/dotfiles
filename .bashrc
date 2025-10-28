# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set variables
is_root=false; [[ $EUID -eq 0 ]] && is_root=true
is_ssh=false; [[ -n "${SSH_CLIENT}" ]] && is_ssh=true
is_termux=false; [[ $(ps -ef|grep -c com.termux ) -gt 1 ]] && is_termux=true

# Configure bash history
shopt -s histappend # Append to the history
HISTCONTROL=ignorespace # Don't put lines starting with space in the history.
HISTSIZE=
HISTFILESIZE=
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Set shell options
shopt -s checkwinsize # Update the values of LINES and COLUMNS.
shopt -s globstar

# Dotfile alias and completion
alias dotgit='/usr/bin/git --git-dir=$HOME/.dotgit/ --work-tree=$HOME'
if [ "$is_termux" = false ]; then
  source /usr/share/bash-completion/completions/git
  __git_complete config __git_main
fi

# Custom functions
export EDITOR=hx
function mans {
  man $1 | less -p "^ +$2"
}
function unix() {
  if [ $# -gt 0 ]; then
    echo "Arg: $(date -d "@$1")"
  fi
  echo "Now: $(date) - $(date +%s)"
}
mkcd () {
  \mkdir -p "$1"
  cd "$1"
}

# LSD aliases
export LS_OPTIONS='-v --color=auto --group-directories-first --date=+%Y%m%d-%H%M%S'
export TREE_OPTIONS=''
export LL_OPTIONS=''
if [ "$is_termux" = true ]; then
  export LL_OPTIONS="--blocks=permission,size,date,name $LL_OPTIONS"
fi
alias ls='LC_COLLATE=C lsd $LS_OPTIONS'
alias ll='ls -lh $LL_OPTIONS'
alias la='ll -a'
alias lt='ls --tree $TREE_OPTIONS'
alias ltl='lt -lh $LL_OPTIONS'
alias lta='ltl -a'

# Always use htop
alias top='htop'

# Test lan speed
alias lanspeed="iperf -c 192.168.188.1 -p 4711"

# Add ADB vendor keys on termux
if [ "$is_termux"=true ]; then
  alias adb='ADB_VENDOR_KEYS=/data/data/com.termux/files/home/adbfiles/adbkey adb'
fi

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Set Theme
export PROMPT_DIRTRIM=2
echo_color() {
  echo -en "\e[${1}m"
}
theme_color() {
  echo -en "\[$(echo_color $1)\]"
}

export GIT_PS1_SHOWDIRTYSTATE=1
source $HOME/.local/bin/git-prompt.sh

color_sign=$(theme_color 0)
color_user=$(theme_color 32)
color_host=$(theme_color 38)
color_ssh=$(theme_color 36)
color_cwd=$(theme_color 37)
color_time=$(theme_color '1;30')
color_reset=$(theme_color 0)

THEME_SIGN="${color_sign}\$${color_reset}"
THEME_USER="${color_user}\u${color_reset}"
THEME_HOST="${color_host}\h${color_reset}"
THEME_SEP=":"
THEME_CWD="${color_cwd}\w${color_reset}"
THEME_TIME="${color_time}\D{%H%M}${color_reset}"
THEME_GIT_BRANCH=' $(__git_ps1 "(%s) ")'
THEME_GIT="${color_user}${THEME_GIT_BRANCH}${color_reset}"
THEME_GREETING=""

if [ "$is_root" = true ]; then
  THEME_SIGN="${color_sign}#${color_reset}"
fi
if [ "$is_termux" = true ]; then
  THEME_USER=""
  THEME_SEP=""
fi
if [ "$is_ssh" = true ]; then
  THEME_USER="${color_ssh}\u${color_reset}@${color_host}\h${color_reset}"
  THEME_SEP=":"
  THEME_GREETING="Connected to $(uname -n)."
fi

PS1="${THEME_TIME} ${THEME_USER}${THEME_SEP}${THEME_CWD}${THEME_GIT}${debian_chroot:+($debian_chroot)}${THEME_SIGN} "

# Greeting
if [ ! -z "$THEME_GREETING" ]; then
  echo -e ${THEME_GREETING}
fi

# Setup rust
if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi

# Set PATH
export PATH="$HOME/.local/bin:$PATH"
export GOPATH="$HOME/go"
export FLUTTERPATH="$HOME/flutter"
export PATH="$GOROOT/bin:$GOPATH/bin:$FLUTTERPATH/bin:$PATH"

# Setup fzf and zoxide
eval "$(fzf --bash)"
eval "$(zoxide init bash)"

# Setup sessions
alias tmx="tmux new -A -s tmx"
alias gui="niri-session"

# Start ssh-agent
if [ "$is_termux" = true ]; then
  export SSH_AUTH_SOCK="$PREFIX"/var/run/ssh-agent.socket
else
  if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
  fi
  if [ ! -f "$SSH_AUTH_SOCK" ]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
  fi
fi

