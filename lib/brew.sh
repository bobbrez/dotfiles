# Homebrew helpers. Source with: source "$MISE_PROJECT_ROOT/lib/brew.sh"

# brew:install runs in its own subshell, so the PATH it sets via `brew shellenv`
# does not carry over to sibling tasks like brew:bundle on a fresh machine.
ensure_brew_on_path() {
  command -v brew >/dev/null 2>&1 && return 0
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# `mas install` on Apple Silicon fails for some apps without Rosetta 2.
# Only needed on arm64; the marker file is Apple's documented detection path.
ensure_rosetta_for_brewfile() {
  local file="$1"
  [[ "$(uname -m)" == "arm64" ]] || return 0
  grep -qE '^[[:space:]]*mas[[:space:]]+"' "$file" || return 0
  [[ -f /Library/Apple/usr/share/rosetta/rosetta ]] && return 0
  echo "==> Installing Rosetta 2 (required by mas entries in $file)"
  sudo softwareupdate --install-rosetta --agree-to-license
}

ensure_brew() {
  local file="$1"
  [[ "${DOTFILES_SKIP_BREW:-}" == "1" ]] && return 0
  [[ -f "$file" ]] || return 0
  ensure_brew_on_path
  ensure_rosetta_for_brewfile "$file"
  echo "==> brew bundle --file=$file"
  brew bundle --file="$file"
}
