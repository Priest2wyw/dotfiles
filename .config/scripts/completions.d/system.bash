#!/usr/bin/env bash

case $- in
  *i*) ;;
  *) return ;;
esac

if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]] && ! shopt -oq posix; then
  if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi
