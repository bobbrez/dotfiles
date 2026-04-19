# Symlink helpers. Source with: source "$MISE_PROJECT_ROOT/lib/symlink.sh"

link_dotfile() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    echo "$dest already linked, skipping"
    return 0
  fi

  if [[ -L "$dest" ]]; then
    echo "Replacing existing symlink $dest -> $(readlink "$dest")"
    rm "$dest"
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
    return 0
  fi

  if [[ ! -e "$dest" ]]; then
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
    return 0
  fi

  if [[ -f "$dest" ]] && diff -q "$src" "$dest" >/dev/null 2>&1; then
    echo "$dest matches $src, replacing with symlink"
    rm "$dest"
    ln -s "$src" "$dest"
    return 0
  fi

  echo
  echo "$dest differs from $src:"
  diff -u "$dest" "$src" || true

  echo
  read -r -p "[b]ackup and link, [s]kip? " choice
  case "$choice" in
    b|B)
      local backup="${dest}.bkup.$(date +%Y%m%d%H%M%S)"
      mv "$dest" "$backup"
      echo "Backed up to $backup"
      ln -s "$src" "$dest"
      echo "Linked $dest -> $src"
      ;;
    *)
      echo "Skipping $dest"
      ;;
  esac
}
