# Neovim

This directory contains the personal [LazyVim](https://www.lazyvim.org/) setup.

What is tracked here:

- `init.lua` bootstraps LazyVim and local plugin specs
- `lazyvim.json` enables the Git, JSON, Markdown, Python, and TOML extras
- `lazy-lock.json` pins plugin revisions for reproducible installs
- `lua/config/` contains local editor behavior
- `lua/plugins/` contains plugin-specific overrides
- `stylua.toml` keeps local Lua formatting consistent

What is not tracked here:

- downloaded plugins and caches under Neovim's data directory
- Mason tool downloads and runtime state
- machine-specific secrets, tokens, or absolute paths

Startup flow:

1. `./install.sh` links this directory to `~/.config/nvim`
2. First `nvim` launch fetches `lazy.nvim`
3. LazyVim installs the plugin set recorded in `lazy-lock.json`
4. Local overrides in `lua/config/` and `lua/plugins/` take effect on top

LazyGit is kept separate and reads `~/.config/lazygit/config.yml`.
