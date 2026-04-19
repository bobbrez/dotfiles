#!/usr/bin/env zsh
# Interactively pick which 1Password SSH keys to sync to ~/.ssh on setup.
# Writes the selection to tasks/1password/1password_keys; the 1password task reads it.
set -e

DOTFILES_PATH=${DOTFILES_PATH:="${0:a:h}"}
KEYS_FILE="$DOTFILES_PATH/tasks/1password/1password_keys"

die() { print -u2 "error: $*"; exit 1; }

command -v op >/dev/null \
  || die "1Password CLI (op) not found. Install via 'brew install --cask 1password-cli' and enable CLI integration in the desktop app."
command -v jq >/dev/null \
  || die "jq not found. Install via 'brew install jq'."

accounts=$(op account list --format=json 2>/dev/null || print "[]")
[[ -n "$accounts" && "$accounts" != "[]" ]] \
  || die "1Password CLI is not connected. In the desktop app: Settings -> Developer -> 'Integrate with 1Password CLI'."

items_json=$(op item list --categories "SSH Key" --format json 2>/dev/null || print "[]")
if [[ "$items_json" == "[]" ]]; then
  print "No SSH keys found in 1Password. Add one in the desktop app, then re-run."
  exit 0
fi

typeset -a item_ids item_titles vault_ids vault_names
while IFS=$'\t' read -r id title vid vname; do
  item_ids+=$id
  item_titles+=$title
  vault_ids+=$vid
  vault_names+=$vname
done < <(print -r -- "$items_json" | jq -r '.[] | [.id, .title, .vault.id, .vault.name] | @tsv')

typeset -A selected_name
for iid in $item_ids; do selected_name[$iid]=""; done

if [[ -f "$KEYS_FILE" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    local f v i
    read -r f v i <<< "$line"
    [[ -n "$i" ]] && selected_name[$i]=$f
  done < "$KEYS_FILE"
fi

slugify() {
  local s=$(print -r -- "${1:l}" | tr -cs 'a-z0-9_-' '_')
  s=${s##_}; s=${s%%_}
  [[ -z "$s" ]] && s=id_key
  print -r -- "$s"
}

render() {
  clear
  print "SSH keys in 1Password — toggle which ones to sync to ~/.ssh"
  print
  local n=${#item_ids[@]}
  for (( i=1; i<=n; i++ )); do
    local iid=${item_ids[$i]}
    local fn=${selected_name[$iid]}
    local mark="[ ]"
    local suffix=""
    if [[ -n "$fn" ]]; then
      mark="[x]"
      suffix="  -> $fn"
    fi
    printf "  %s %2d. %-32s (%s)%s\n" "$mark" "$i" "${item_titles[$i]}" "${vault_names[$i]}" "$suffix"
  done
  print
  print "Commands:"
  print "  <n>           toggle selection"
  print "  <n> <name>    set local filename for key <n>"
  print "  s             save to $KEYS_FILE and exit"
  print "  q             quit without saving"
}

save_and_exit() {
  mkdir -p "${KEYS_FILE:h}"
  local tmp=$(mktemp)
  {
    print "# Managed by ssh_keys.zsh — 1Password SSH keys to sync on setup"
    print "# Format: <filename> <vault_id> <item_id>"
    local n=${#item_ids[@]}
    for (( i=1; i<=n; i++ )); do
      local iid=${item_ids[$i]}
      local fn=${selected_name[$iid]}
      [[ -n "$fn" ]] && print "$fn ${vault_ids[$i]} $iid"
    done
  } > "$tmp"
  mv "$tmp" "$KEYS_FILE"
  print "Saved $KEYS_FILE"
  exit 0
}

while true; do
  render
  local input
  read "input?> " || break
  input="${input## }"; input="${input%% }"
  [[ -z "$input" ]] && continue
  case "$input" in
    q|Q) print "Aborted."; exit 0 ;;
    s|S) save_and_exit ;;
    *)
      local num=${input%% *}
      local rest=""
      [[ "$input" == *" "* ]] && rest="${input#* }"
      if [[ "$num" != <-> ]]; then
        print "Unknown command: $input"
        read -k 1 "?(press any key) "
        continue
      fi
      if (( num < 1 || num > ${#item_ids[@]} )); then
        print "Out of range: $num"
        read -k 1 "?(press any key) "
        continue
      fi
      local iid=${item_ids[$num]}
      if [[ -n "$rest" ]]; then
        selected_name[$iid]=$rest
      elif [[ -n "${selected_name[$iid]}" ]]; then
        selected_name[$iid]=""
      else
        selected_name[$iid]=$(slugify "${item_titles[$num]}")
      fi
      ;;
  esac
done
