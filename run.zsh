#!/usr/bin/env zsh
set -e

autoload -Uz colors && colors

if ! command -v brew &> /dev/null; then
    print "\n${fg_bold[cyan]}Installing Homebrew${reset_color}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print "\n${fg_bold[cyan]}Updating Homebrew${reset_color}"
    brew update
fi

DOTFILES_PATH=${DOTFILES_PATH:="${0:a:h}"}
TASKS_DIR="$DOTFILES_PATH/tasks"

if [[ -f "$DOTFILES_PATH/Brewfile" ]]; then
  print "\n${fg_bold[cyan]}Installing $DOTFILES_PATH/Brewfile${reset_color}"
  brew bundle --file="$DOTFILES_PATH/Brewfile"
fi

# Default task order — homebrew first so brew is available for later tasks.
# Tasks not listed here run after, in alphabetical order.
typeset -a default_order=(1password ssh git zsh iterm2 osx)

typeset -a requested_tasks
while (( $# )); do
  case "$1" in
    --tasks)
      shift
      [[ -z "$1" ]] && { print -u2 "error: --tasks requires a value"; exit 1; }
      requested_tasks=(${(s:,:)${1// /}})
      shift
      ;;
    --tasks=*)
      requested_tasks=(${(s:,:)${${1#--tasks=}// /}})
      shift
      ;;
    -h|--help)
      print "Usage: setup.zsh [--tasks task1,task2,...]"
      print
      print "Available tasks:"
      for d in $TASKS_DIR/*(N/); do
        [[ -f "$d/task" ]] && print "  ${d:t}"
      done
      exit 0
      ;;
    *)
      print -u2 "error: unknown argument: $1"
      exit 1
      ;;
  esac
done

typeset -a task_names
if (( ${#requested_tasks[@]} )); then
  task_names=($requested_tasks)
  for name in $task_names; do
    [[ -f "$TASKS_DIR/$name/task" ]] \
      || { print -u2 "error: unknown task '$name' (no $TASKS_DIR/$name/task)"; exit 1; }
  done
else
  for name in $default_order; do
    [[ -f "$TASKS_DIR/$name/task" ]] && task_names+=$name
  done
  for d in $TASKS_DIR/*(N/); do
    local n=${d:t}
    [[ -f "$d/task" ]] || continue
    (( ${task_names[(Ie)$n]} )) || task_names+=$n
  done
fi

for name in $task_names; do
  print "\n${fg_bold[cyan]}Starting Task ${name}${reset_color}"
  (
    local task_dir="$TASKS_DIR/$name"
    for bf in $task_dir/*.Brewfile(N); do
      print "${fg_bold[cyan]}Installing ${bf:t}${reset_color}"
      brew bundle --file="$bf"
    done
    __run_task() { source "$task_dir/task" }
    __run_task
  )
done

print "\n${fg_bold[green]}All tasks completed${reset_color}"