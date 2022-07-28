# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Configure bash history
shopt -s histappend # Append to the history
HISTCONTROL=ignoreboth # Don't put duplicate lines or lines starting with space in the history.
HISTSIZE=1000
HISTFILESIZE=2000

# Set shell options
shopt -s checkwinsize # Update the values of LINES and COLUMNS.
shopt -s globstar

# Dotfile alias and completion
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
source /usr/share/bash-completion/completions/git
__git_complete config __git_main

# Custom functions
function mans {
       man $1 | less -p "^ +$2"
}

# Colorize LS
export LS_OPTIONS='--color=auto'
#eval "$(dircolors)"
eval "$(dircolors -b ~/.dircolors)"
alias ls='LC_COLLATE=C ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lhA'

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Set Theme
export PROMPT_DIRTRIM=2
theme_color() {
  echo -en "\[\e[${1}m\]"
}
export GIT_PS1_SHOWDIRTYSTATE=1
source $HOME/.local/bin/git-prompt.sh

color_sign=$(theme_color 0)
color_user=$(theme_color 32)
color_host=$(theme_color 38)
color_ssh=$(theme_color 36)
color_cwd=$(theme_color 37)
color_reset=$(theme_color 0)

THEME_SIGN="${color_sign}\$${color_reset}"
THEME_USER="${color_user}\u${color_reset}"
THEME_HOST="${color_host}\h${color_reset}"
THEME_CWD="${color_cwd}\w${color_reset}"
THEME_GIT_BRANCH=' $(__git_ps1 "(%s) ")'
THEME_GIT="${color_user}${THEME_GIT_BRANCH}${color_reset}"

if [[ $EUID -eq 0 ]]; then
  THEME_SIGN="${color_sign}#${color_reset}"
fi
if [[ -n "${SSH_CLIENT}" ]]; then
  THEME_USER="${color_ssh}\u${color_reset}@${color_host}\h${color_reset}"
fi

PS1="\D{%H%M} ${THEME_USER}:${THEME_CWD}${THEME_GIT}${debian_chroot:+($debian_chroot)}${THEME_SIGN} "

# Setup rust
if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi

# Set PATH
export "PATH=$HOME/.local/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
