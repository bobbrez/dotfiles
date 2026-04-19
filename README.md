# dotfiles

Personal macOS setup: Homebrew packages, shell configuration, SSH keys from 1Password, macOS defaults, and per-app configs — driven by a single `run` entrypoint.

## Quick Start

On a fresh Mac, paste this into Terminal:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobbrez/dotfiles/HEAD/install.sh)"
```

[install.sh](install.sh) clones the repo to `~/.dotfiles` (or updates it if already present), then hands off to [run](run), which installs Homebrew if missing, bundles the root [Brewfile](Brewfile), and runs every task in [tasks/](tasks/).

Override the clone location or source repo via env vars:

```sh
DOTFILES_PATH=~/code/dotfiles /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobbrez/dotfiles/HEAD/install.sh)"
```

## How it works

[run](run) is the entrypoint. It:

1. Installs or updates Homebrew (unless `--skip-brew` is passed).
2. Bundles the root [Brewfile](Brewfile) — shared packages used across tasks.
3. Runs each task in [tasks/](tasks/), in a fixed order (`1password`, `ssh`, `git`, `zsh`, `iterm2`, `osx`), with any other tasks appended alphabetically.

Each task lives in `tasks/<name>/` and consists of:

- `task` — a zsh script that is sourced to do the work.
- `configure` (optional) — a zsh script for interactive setup. Run via `./configure <name>` from the repo root.
- `*.Brewfile` (optional) — bundled automatically before `task` runs, so the task can rely on those packages.
- Any config files the task manages (e.g. `gitconfig`, `zshrc`, `config`).

### Flags

- `--tasks task1,task2,...` — run only the listed tasks.
- `--skip-brew` — skip all Homebrew operations (install/update, root Brewfile, per-task Brewfiles). Useful for re-runs when packages are already current.
- `-h`, `--help` — list available tasks.

Examples:

```sh
./run --tasks git,zsh       # only reconfigure git and zsh
./run --skip-brew           # rerun tasks without touching Homebrew
```

## Tasks

| Task | What it does |
| --- | --- |
| [1password](tasks/1password/) | Verifies the 1Password CLI is connected, then syncs SSH keys listed in `1password_keys` into `~/.ssh` and adds them to the Apple keychain. |
| [ssh](tasks/ssh/) | Symlinks [tasks/ssh/config](tasks/ssh/config) to `~/.ssh/config` (backing up any existing file). |
| [git](tasks/git/) | Symlinks [gitconfig](tasks/git/gitconfig) and [gitignore](tasks/git/gitignore) into `$HOME`, and pins the repo's `origin` remote. |
| [zsh](tasks/zsh/) | Installs / updates Oh My Zsh, Powerlevel10k, and Powerline fonts; symlinks the custom `zshrc` and `p10k.zsh`. |
| [iterm2](tasks/iterm2/) | Installs iTerm2 via Brewfile (preferences currently commented out in the task). |
| [osx](tasks/osx/) | Applies macOS defaults (Finder, Dock, keyboard repeat, screensaver, etc.). Writes `~/.osx_setup` so it only runs once — delete that file to re-run. |

## Configure

Some tasks need interactive setup. Run the root [configure](configure) script with a task name:

```sh
./configure 1password     # pick which 1Password SSH keys to sync
./configure brew          # edit the root Brewfile against what's installed
```

It dispatches to `tasks/<name>/configure`. Currently available:

- [tasks/1password/configure](tasks/1password/configure) — lists every SSH Key item in connected 1Password accounts and lets you toggle which ones to sync and what local filename to use. Writes `tasks/1password/1password_keys` (gitignored), which the `1password` task reads on subsequent runs.
- [tasks/brew/configure](tasks/brew/configure) — shows a superset of entries in the root [Brewfile](Brewfile) and what's currently installed (via `brew bundle dump`), tagged as `tracked + installed`, `tracked, MISSING`, or `installed, not tracked`. Toggling checkboxes rewrites the Brewfile with the selected entries. Does not install or uninstall anything — that's `./run`'s job.

## Re-running

The setup is idempotent. Common re-run patterns:

```sh
./run                       # full refresh after pulling changes
./run --skip-brew           # fast re-run, skip Homebrew entirely
./run --tasks osx           # reapply just macOS defaults (remove ~/.osx_setup first)
```
