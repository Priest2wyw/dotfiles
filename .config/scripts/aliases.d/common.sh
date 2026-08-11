#!/usr/bin/env bash

if command -v dircolors >/dev/null 2>&1; then
  if [[ -r "$HOME/.dircolors" ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'

alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph -20'

if command -v notify-send >/dev/null 2>&1; then
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history 1 | sed -E '\''s/^[[:space:]]*[0-9]+[[:space:]]*//; s/[;&|][[:space:]]*alert$//'\'')"'
fi

mkcd() {
  if [[ $# -ne 1 ]]; then
    echo "用法：mkcd <目录>" >&2
    return 2
  fi

  mkdir -p -- "$1" && cd -- "$1"
}

croot() {
  local root

  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "错误：当前目录不在 Git 仓库中。" >&2
    return 1
  }
  cd -- "$root"
}
