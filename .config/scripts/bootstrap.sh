#!/usr/bin/env bash

SCRIPTS_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/scripts"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":$PATH:" in
  *":$SCRIPTS_HOME/bin:"*) ;;
  *) export PATH="$SCRIPTS_HOME/bin:$PATH" ;;
esac

for f in "$SCRIPTS_HOME/env.d/"*.sh; do
  [ -f "$f" ] && . "$f"
done

for f in "$SCRIPTS_HOME/aliases.d/"*.sh; do
  [ -f "$f" ] && . "$f"
done

for f in "$SCRIPTS_HOME/completions.d/"*.bash; do
  [ -f "$f" ] && . "$f"
done
