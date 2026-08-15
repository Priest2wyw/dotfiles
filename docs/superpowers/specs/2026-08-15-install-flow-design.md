# Dotfiles Install Flow Design

## Context

The current `install.sh` only creates config symlinks and prints manual next steps.
It does not install system packages, does not ask the user what to include, and
always handles Clash as part of the default flow.

The new workflow must support a plain Bash, low-dependency install process with:

- a text-based component list
- per-item selection before execution
- a final plan preview
- a second confirmation before any changes are applied
- Clash excluded by default

## Goals

1. Let the user choose which components to install or skip from a textual list.
2. Show a concrete execution plan before making changes.
3. Run the approved plan in one execution pass.
4. Keep the implementation dependency-free beyond standard shell tools and the
   commands already used by this repository.
5. Preserve the existing backup behavior for conflicting target paths.
6. Keep Clash optional and off by default.

## Non-Goals

- Fancy UI widgets
- `fzf`, `whiptail`, or similar extra dependencies
- Cross-distro package management
- Automatic handling of secrets, subscriptions, or machine-specific credentials
- Silent background setup without user confirmation

## Proposed User Flow

1. Probe the local machine and build a component inventory.
2. Present a numbered list with default selections.
3. Let the user toggle items on or off using plain text input.
4. Render a final plan with the actions grouped by type.
5. Ask for one last confirmation.
6. Execute the approved plan.

## Component Model

Each selectable item is represented as a small record with:

- `id`: stable internal name
- `label`: human-readable name
- `kind`: package, symlink, shell-integration, service, or post-install task
- `default_selected`: whether it starts selected
- `enabled`: whether the current machine can execute it now
- `dependencies`: prerequisite items that must be selected first
- `action`: shell code that performs the step
- `verify`: optional check used to confirm success

### Planned Components

- Base packages: `git`, `bash`, `tmux`, `neovim`, `python3`, `python3-pip`
- Optional package: `lazygit`
- Config links: `scripts`, `nvim`, `lazygit`, `tmux`, `uv`
- Shell integration: add `source ~/.config/scripts/bootstrap.sh` to `~/.bashrc`
- Neovim bootstrap: first-run plugin sync after config is linked
- Clash group: `clash` config link, user service link, and compose startup

## Package Installation Policy

The first implementation targets the current Ubuntu/Debian-style environment and
uses `apt` for package installation. It should not add PPAs, install snaps, or
download third-party release archives.

Detection should prefer executable checks such as `command -v nvim` over package
database checks, because an installed package is not useful if the expected
command is not available in `PATH`.

If a selected package has no install candidate in the configured `apt`
repositories, the script should mark that item as unavailable and report a
manual follow-up instead of guessing another install method. This is especially
important for `lazygit`, which may not exist in every Ubuntu repository.

## Defaults

The install screen should default to the common non-Clash setup:

- selected by default: core package install, config links, tmux setup
- selected by default: `uv` link if present in the repository
- not selected by default: `.bashrc` integration
- not selected by default: Neovim first-run sync
- not selected by default: Clash

This keeps the first run conservative while still allowing the user to opt in to
more automated behavior.

## Selection UX

The selector stays in plain Bash. The user can:

- toggle an item by number
- select or clear all items in a group
- continue to the plan preview
- go back and adjust the list if the preview looks wrong

The output should be readable in a terminal with no terminal UI libraries.
The format can stay simple, for example:

```text
[x] 1. Install core packages
[x] 2. Link nvim config
[ ] 3. Add ~/.bashrc entry
[ ] 4. Start Clash
```

## Execution Flow

The implementation should keep the flow in one script, but with separate internal
phases:

1. `probe_environment`
   - detect missing commands
   - detect existing config paths
   - detect whether tmux submodule content is present
2. `build_selection`
   - create the selectable component list
   - apply defaults
3. `render_plan`
   - summarize selected actions
   - show what will be installed, linked, enabled, or skipped
4. `confirm_plan`
   - require explicit user approval
5. `execute_plan`
   - run steps in dependency order
   - stop on hard failure
   - keep successful steps in place

## Error Handling

- If a prerequisite command is missing, mark the related item as unavailable
  rather than guessing a fix.
- If package installation fails, stop the dependent steps and report the exact
  failing command.
- If a target path already exists, keep the current backup-and-relink behavior.
- If Clash is not selected, do not create or modify any Clash paths.
- If the user declines the final confirmation, exit without changes.

## Plan Ordering

The execution order should be stable and predictable:

1. Install missing base packages.
2. Install optional selected packages.
3. Link repository configs.
4. Apply shell integration if selected.
5. Run Neovim bootstrap if selected and available.
6. Apply Clash actions only if Clash was explicitly selected.

This order keeps the environment usable as soon as possible and avoids running
dependent tasks before their prerequisites exist.

## Verification Strategy

The implementation should be testable with a temporary home directory and a
temporary XDG config directory.

Expected checks:

- selection state is parsed correctly
- plan preview matches the selected items
- Clash remains untouched when unselected
- backup behavior still works for conflicting paths
- plan generation can be exercised without affecting the real home

## Acceptance Criteria

- The script asks the user what to install before doing anything destructive.
- The script shows a plan before execution and requires a second confirmation.
- The user can exclude Clash completely.
- The flow stays dependency-light and works with standard Bash tooling.
- Existing config backup behavior is preserved.

## Open Questions Resolved

- The UI does not need to be pretty.
- Extra menu dependencies are out of scope.
- Clash is a selectable component, not part of the default path.
- `install.sh` remains the entry point.
