#!/usr/bin/env bash
set -euo pipefail

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
fi

cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
template="$HOME/dotfiles/herdr/spreader/config.yaml"
binary="$(herdr plugin config-dir herdr-spreader)/nix-build/bin/herdr-spreader"
dev_bin="/opt/dev/bin/dev"

fail() {
  printf '%s\n' "$1"
  if [[ -t 0 ]]; then
    read -r -p "Press Enter to close..." _
  fi
  exit 1
}

if [[ ! -x "$binary" ]]; then
  fail $'Spreader is not ready. Run:\n  ~/dotfiles/herdr/spreader/fix-macos-build.sh'
fi

if [[ "$cwd" =~ /world/trees/([^/]+)/src(/|$) ]]; then
  default_name="${BASH_REMATCH[1]}"
else
  default_name="$(basename "$cwd")"
fi

existing_trees=""
if [[ -x "$dev_bin" ]]; then
  existing_trees="$("$dev_bin" tree list --ids-only 2>/dev/null || true)"
fi

tree_options=()
if [[ -n "$existing_trees" ]]; then
  while IFS= read -r tree_line; do
    [[ -n "$tree_line" ]] && tree_options+=("$tree_line")
  done <<< "$existing_trees"
fi

dev_cd_options=("shopify-playground/georgef" "shopify/second-brain" "shopify" "admin-web")

# fzf_pick PROMPT HEADER < options
# Prints the chosen value: the highlighted item, or (if none matched) whatever
# was typed, so a custom/new value is accepted just by typing it. Prints nothing
# when the picker is cancelled with Esc/Ctrl-C, meaning "skip / stay put".
fzf_pick() {
  local prompt="$1" header="$2" out status query selection
  out="$(fzf --prompt="$prompt" --header="$header" --height=40% --reverse \
            --border --info=inline --print-query --no-multi)"
  status=$?
  (( status == 130 )) && return 0
  query="$(sed -n '1p' <<< "$out")"
  selection="$(sed -n '2p' <<< "$out")"
  printf '%s' "${selection:-$query}"
}

if [[ -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  read -r -p "Workspace name [$default_name]: " workspace_name
  dev_target="$(printf '%s\n' "${dev_cd_options[@]}" | fzf_pick 'dev cd> ' 'enter to pick, type a custom target, or Esc to skip (none)')"
  worktree="$(printf '%s\n' "${tree_options[@]}" | fzf_pick 'worktree> ' 'enter to pick, type a new/existing name, or Esc to keep current')"
elif [[ -t 0 ]]; then
  read -r -p "Workspace name [$default_name]: " workspace_name

  printf 'dev cd target:\n'
  index=1
  for target_line in "${dev_cd_options[@]}"; do
    printf '  %2d) %s\n' "$index" "$target_line"
    index=$((index + 1))
  done
  none_target=$index
  printf '  %2d) none (stay in this directory)\n' "$index"
  index=$((index + 1))
  other_target=$index
  printf '  %2d) other (type a target)\n' "$index"
  read -r -p "Select [$none_target]: " target_choice
  target_choice="${target_choice:-$none_target}"

  if [[ "$target_choice" == "$none_target" ]]; then
    dev_target=""
  elif [[ "$target_choice" == "$other_target" ]]; then
    read -r -p "dev cd target: " dev_target
  elif [[ "$target_choice" =~ ^[0-9]+$ ]] && (( target_choice >= 1 && target_choice <= ${#dev_cd_options[@]} )); then
    dev_target="${dev_cd_options[$((target_choice - 1))]}"
  else
    dev_target="$target_choice"
  fi

  printf 'Worktree:\n'
  index=1
  for tree_line in "${tree_options[@]}"; do
    printf '  %2d) %s\n' "$index" "$tree_line"
    index=$((index + 1))
  done
  current_choice=$index
  printf '  %2d) current (stay in this tree)\n' "$index"
  index=$((index + 1))
  other_choice=$index
  printf '  %2d) other (type a name)\n' "$index"
  read -r -p "Select [$current_choice]: " choice
  choice="${choice:-$current_choice}"

  if [[ "$choice" == "$current_choice" ]]; then
    worktree=""
  elif [[ "$choice" == "$other_choice" ]]; then
    read -r -p "Worktree name (existing or new): " worktree
  elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#tree_options[@]} )); then
    worktree="${tree_options[$((choice - 1))]}"
  else
    worktree="$choice"
  fi
else
  IFS= read -r workspace_name || true
  IFS= read -r dev_target || true
  IFS= read -r worktree || true
fi

workspace_name="${workspace_name:-$default_name}"
worktree="$(printf '%s' "${worktree:-}" | xargs)"
dev_target="$(printf '%s' "${dev_target:-}" | xargs)"

# Build the shell prefix each pane runs before its own command, ordered
# dev cd -> dev tree -> apps: `dev cd` sets the zone, then `dev tree switch`
# carries that same zone path into the target tree, then the app command runs.
# Resolving or creating the worktree here (not per pane) avoids a duplicate-add
# race across the three panes; each pane then only needs an idempotent switch.
tree_cmd=""
if [[ -n "$worktree" ]]; then
  if printf '%s\n' "$existing_trees" | grep -Fxq -- "$worktree"; then
    tree_cmd="dev tree switch $worktree"
  else
    if [[ "$dry_run" == false ]]; then
      [[ -x "$dev_bin" ]] || fail "dev not found at $dev_bin; cannot create worktree '$worktree'."
      if ! add_output="$("$dev_bin" tree add "$worktree" 2>&1)"; then
        fail $'Failed to create worktree \''"$worktree"$'\':\n'"$add_output"
      fi
    fi
    tree_cmd="dev tree switch $worktree"
  fi
fi

prefix=""
[[ -n "$dev_target" ]] && prefix="dev cd $dev_target"
if [[ -n "$tree_cmd" ]]; then
  prefix="${prefix:+$prefix && }$tree_cmd"
fi

layout=$(mktemp)
trap 'rm -f "$layout"' EXIT

# System Ruby's YAML works only with a clean environment (Nix gem paths break it),
# so run the transform under env -i with the absolute interpreter path.
env -i /usr/bin/ruby -ryaml -e '
  template, dest, name, prefix = ARGV
  data = YAML.load_file(template)
  workspace = data.fetch("workspaces").first
  workspace["name"] = name
  workspace.fetch("tabs", []).each do |tab|
    (tab["panes"] || []).each do |pane|
      existing = pane["command"].to_s
      parts = []
      parts << prefix unless prefix.nil? || prefix.empty?
      parts << existing unless existing.empty?
      if parts.empty?
        pane.delete("command")
      else
        pane["command"] = parts.join(" && ")
      end
    end
  end
  File.write(dest, YAML.dump(data))
' "$template" "$layout" "$workspace_name" "$prefix" 2>/dev/null

arguments=(apply --file "$layout")
if [[ "$dry_run" == true ]]; then
  arguments+=(--dry-run)
fi

cd "$cwd"
if "$binary" "${arguments[@]}"; then
  exit 0
else
  status=$?
  printf '\nSpreader failed with status %s.\n' "$status"
  if [[ -t 0 ]]; then
    read -r -p "Press Enter to close..." _
  fi
  exit "$status"
fi
