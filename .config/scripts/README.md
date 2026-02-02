# Scripts

Goal: keep personal scripts in one place with a single, stable bashrc entry.

## Layout

```
~/.config/scripts/
  bootstrap.sh     # the only bashrc entry
  bin/             # executables (command name = file name)
  lib/             # shared helpers for scripts
  env.d/           # env var fragments
  aliases.d/       # alias fragments
  completions.d/   # bash completion fragments
```

## Usage

1) Add one line to `~/.bashrc`:

```bash
source ~/.config/scripts/bootstrap.sh
```

2) Drop a script into `bin/` and make it executable:

```bash
chmod +x ~/.config/scripts/bin/xxx
```

## Design

- `bootstrap.sh` adds `bin/` to `PATH` and sources `env.d/`, `aliases.d/`, `completions.d/`
- new scripts require no bashrc changes
- easy to move: repo links to `~/.config/scripts`
