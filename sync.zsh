#!/usr/bin/env zsh
set -e

DOTFILES_PATH=${DOTFILES_PATH:="${0:a:h}"}

brew bundle dump --force --file "$DOTFILES_PATH/tasks/homebrew/all.Brewfile"
