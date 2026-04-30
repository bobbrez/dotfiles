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

# Prime sudo and keep its 5-minute timestamp warm for the lifetime of $$.
# Cask and `softwareupdate` invocations call sudo themselves; without this
# they re-prompt every time the timestamp expires mid-bundle. Idempotent.
start_sudo_keepalive() {
  [[ -n "${_DOTFILES_SUDO_KEEPALIVE_PID:-}" ]] && return 0
  [[ "${DOTFILES_SKIP_BREW:-}" == "1" ]] && return 0
  # Best-effort: if there's no TTY (CI, non-interactive), skip and let
  # casks prompt as they normally would rather than aborting the run.
  sudo -v 2>/dev/null || { echo "==> sudo unavailable; cask installs may prompt individually" >&2; return 0; }
  ( while kill -0 "$$" 2>/dev/null; do
      sudo -n true 2>/dev/null || exit
      sleep 50
    done ) &
  _DOTFILES_SUDO_KEEPALIVE_PID=$!
  trap 'kill "$_DOTFILES_SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
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
