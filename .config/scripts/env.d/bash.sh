#!/usr/bin/env bash

if [[ -n "${BASH_VERSION:-}" ]]; then
  export HISTCONTROL=ignoreboth
  export HISTSIZE=1000
  export HISTFILESIZE=2000
  shopt -s histappend checkwinsize
fi
