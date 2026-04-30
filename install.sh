#!/bin/bash
set -e

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/bobbrez/dotfiles.git}"

if ! command -v git >/dev/null 2>&1; then
  echo "git not found -- installing Xcode Command Line Tools..."
  xcode-select --install || true
  echo "Re-run this command once the Command Line Tools finish installing."
  exit 1
fi

if [ ! -d "$DOTFILES_PATH/.git" ]; then
  echo "Cloning $DOTFILES_REPO into $DOTFILES_PATH"
  git clone "$DOTFILES_REPO" "$DOTFILES_PATH"
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "Installing mise"
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

cd "$DOTFILES_PATH"
mise run apply "$@"

# Sync to origin only after a successful apply, so a failed run leaves the
# working tree alone for debugging and doesn't fast-forward over local edits
# mid-flight. New upstream changes are picked up on the next install.sh run.
echo "==> Syncing $DOTFILES_PATH with origin"
git -C "$DOTFILES_PATH" pull --ff-only \
  || echo "warning: pull --ff-only failed (local commits or diverged); skipping."
