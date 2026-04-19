# Homebrew helpers. Source with: source "$MISE_PROJECT_ROOT/lib/brew.sh"

ensure_brew() {
  local file="$1"
  [[ "${DOTFILES_SKIP_BREW:-}" == "1" ]] && return 0
  [[ -f "$file" ]] || return 0
  echo "==> brew bundle --file=$file"
  brew bundle --file="$file" --no-lock
}
