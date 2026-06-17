#!/usr/bin/env bash
# Print tmux-formatted git branch + worktree segment for the status bar.
# Usage: git-status.sh <pane_current_path>

set -e

path="${1:-$PWD}"
cd "$path" 2>/dev/null || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
[ -z "$branch" ] && exit 0

top=$(git rev-parse --show-toplevel 2>/dev/null)
worktree=$(echo "$top" | sed -n 's|.*/trees/\([^/]*\).*|\1|p')

# Colors (Rose Pine palette)
LABEL='#[fg=#908caa]'
WT='#[fg=#c4a7e7]'        # iris
BR_ICON='#[fg=#c4a7e7]'   # iris (purple) for branch glyph
BR='#[fg=#ebbcba]'        # rose
SEP='#[fg=#6e6a86] · '    # muted
RESET='#[default]'

# Truncate worktree to 22 chars
truncate() {
  local s="$1" max=22
  if [ "${#s}" -gt "$max" ]; then
    echo "${s:0:max}…"
  else
    echo "$s"
  fi
}

if [ -n "$worktree" ]; then
  wt_short=$(truncate "$worktree")
  printf '%s🌳 %s%s%s⎇ %s %s%s' "$WT" "$wt_short" "$SEP" "$BR_ICON" "$BR" "$branch" "$RESET"
else
  printf '%s⎇ %s %s%s' "$BR_ICON" "$BR" "$branch" "$RESET"
fi
