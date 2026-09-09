#!/usr/bin/env bash
# Opens lazygit in a herdr popup over the focused pane's directory.
# Bound to prefix+g in config.toml. Aborts with a message if the pane's
# cwd is not inside a git repo.
set -euo pipefail

cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"

if ! git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Not a git repo: %s\n' "$cwd"
  if [[ -t 0 ]]; then
    read -r -p "Press Enter to close..." _
  fi
  exit 1
fi

cd "$cwd"
exec lazygit
