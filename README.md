# dotfiles

Personal macOS setup: Homebrew packages, shell configuration, SSH keys from 1Password, macOS defaults, and per-app configs — orchestrated by [mise](https://mise.jdx.dev/) tasks.

## Quick Start

On a fresh Mac, paste this into Terminal:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobbrez/dotfiles/HEAD/install.sh)"
```

[install.sh](install.sh) clones the repo to `~/.dotfiles` (or updates it if already present), installs `mise` if missing, then runs `mise run apply`.

Override the clone location or source repo via env vars:

```sh
DOTFILES_PATH=~/code/dotfiles /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobbrez/dotfiles/HEAD/install.sh)"
```

## How it works

The task graph lives in [mise.toml](mise.toml). The default entrypoint is `mise run apply`, which depends on each task's `<name>:apply` in a fixed order. Each task is a standalone script under [tasks/](tasks/) with a `#MISE` frontmatter declaring its description, dependencies, and source files (for change detection).

Tasks with multiple phases (`brew`, `1password`) decompose into sub-verbs — `bundle`, `check`, `install`, `sync` — and their `apply` is an orchestrator that depends on the right phases.

```sh
mise tasks           # list all tasks
mise run apply       # full machine apply
mise run git:apply   # run a single task
mise run osx:apply   # reapply macOS defaults (remove .osx_setup first)
```

Set `DOTFILES_SKIP_BREW=1` to skip all Homebrew operations on re-run.

## Tasks

Every task exposes `<name>:apply` as its public entry point. Tasks that decompose expose sub-verbs too.

| Task | What it does |
| --- | --- |
| [brew:apply](tasks/brew/apply) | Install Homebrew and bundle the root [Brewfile](Brewfile). Orchestrates `brew:install` + `brew:bundle`. |
| [brew:install](tasks/brew/install) | Install Homebrew if missing, otherwise `brew update`. |
| [brew:bundle](tasks/brew/bundle) | Bundle the root [Brewfile](Brewfile) — shared packages. |
| [brew:configure](tasks/brew/configure) | Interactive TUI for editing the root Brewfile. |
| [1password:apply](tasks/1password/apply) | Full 1Password SSH key sync. Orchestrates `bundle` + `check` + `configure`-if-needed + `sync`. |
| [1password:bundle](tasks/1password/bundle) | Install the 1Password CLI and runtime deps (gum). |
| [1password:check](tasks/1password/check) | Verify `op` CLI is installed and connected; prompts for setup if not. |
| [1password:sync](tasks/1password/sync) | Fetch SSH keys listed in `1password_keys` into `~/.ssh` and add to the Apple keychain. |
| [1password:configure](tasks/1password/configure) | Interactive TUI to pick which 1Password SSH keys to sync. |
| [ssh:apply](tasks/ssh/apply) | Symlink [tasks/ssh/config](tasks/ssh/config) to `~/.ssh/config`. |
| [git:apply](tasks/git/apply) | Symlink [gitconfig](tasks/git/gitconfig) and [gitignore](tasks/git/gitignore) into `$HOME`, pin the repo's `origin` remote. |
| [zsh:apply](tasks/zsh/apply) | Install / update Oh My Zsh, Powerlevel10k, Powerline fonts; symlink the custom `zshrc` and `p10k.zsh`. |
| [iterm2:apply](tasks/iterm2/apply) | Install iTerm2 via per-task Brewfile. |
| [claude:apply](tasks/claude/apply) | Install Claude app, Claude Code, VS Code, and the Claude Code extension. |
| [osx:apply](tasks/osx/apply) | Apply macOS defaults. Writes `.osx_setup` at the repo root — delete to re-run. |

## Task anatomy

Each `tasks/<name>/` directory contains:

- `apply` — the canonical entry point, with `#MISE` frontmatter
- Optional sub-verb scripts (`bundle`, `check`, `install`, `sync`) when the task has real phases
- Optional `configure` — interactive setup, run via `mise run <name>:configure`
- Optional `*.Brewfile` — plain Brewfiles, bundled via the `ensure_brew` helper
- Any config files the task manages (e.g. `gitconfig`, `zshrc`, `config`)

## Helpers

Shared shell helpers live in [lib/](lib/):

- [lib/brew.sh](lib/brew.sh) — `ensure_brew` (skips on `DOTFILES_SKIP_BREW=1`)
- [lib/symlink.sh](lib/symlink.sh) — `link_dotfile` (idempotent symlink with diff/backup prompt)

Source them from a task with `source "$MISE_PROJECT_ROOT/lib/brew.sh"`.

## Adding a new task

1. Create `tasks/<name>/apply` (executable), with `#MISE` frontmatter.
2. If the task needs packages, add a `Brewfile` next to it and `ensure_brew` it from `apply` (or decompose into a `bundle` sub-verb if you want it re-runnable on its own).
3. Add `"<name>:apply"` to the `apply` task's `depends` list in [mise.toml](mise.toml).

Example — adding a Terraform task:

```sh
mkdir tasks/terraform
cat > tasks/terraform/Brewfile <<EOF
brew "terraform"
brew "tflint"
EOF
cat > tasks/terraform/apply <<'EOF'
#!/usr/bin/env bash
#MISE description="Terraform tooling"
#MISE depends=["brew:apply"]
#MISE sources=["tasks/terraform/Brewfile"]
set -euo pipefail

source "$MISE_PROJECT_ROOT/lib/brew.sh"
ensure_brew "$MISE_PROJECT_ROOT/tasks/terraform/Brewfile"
EOF
chmod +x tasks/terraform/apply
```

Then add `"terraform:apply"` to `apply.depends` in [mise.toml](mise.toml).

## Re-running

All tasks are idempotent. Common patterns:

```sh
mise run apply                       # full refresh after pulling changes
DOTFILES_SKIP_BREW=1 mise run apply  # fast re-run, skip Homebrew
mise run osx:apply                   # reapply just macOS defaults (rm .osx_setup first)
mise run 1password:sync              # just re-sync keys (skip checks + configure)
```
