# Active Pane Sidebar

A local Herdr plugin that makes each workspace row describe its focused pane.

It reports five custom workspace tokens:

- `active_dir`: `📁` plus the repository-relative directory, or an abbreviated absolute path
- `worktree`: `🌳` plus the World tree or linked Git worktree name
- `branch`: `⎇` plus the Git branch or detached commit
- `git_state`: `✓` when clean, or `●` plus ahead/behind arrows when changed
- `pane_context`: active tab and detected agent state

## Install

```bash
herdr plugin link ~/dotfiles/herdr/plugins/active-pane-sidebar
```

Add these rows to `~/.config/herdr/config.toml`:

```toml
[ui.sidebar.spaces]
row_gap = 0
rows = [
  ["state_icon", "workspace"],
  ["$active_dir"],
  ["$worktree"],
  ["$branch", "$git_state"],
  ["$pane_context"],
]
```

Then reload and seed the current workspace:

```bash
herdr server reload-config
herdr plugin action invoke georgef.active-pane-sidebar.refresh
```

## Refresh behavior

Manifest hooks refresh metadata when pane, tab, workspace, worktree, or agent focus/state changes. The zsh `precmd` hook in `nix/home/programs/zsh/default.nix` also refreshes after each shell command, so `cd` and Git changes appear without a polling process.

Only the focused pane for a workspace may update that workspace's tokens. A prompt completing in another split cannot overwrite the displayed context.

Git commands have a three-second timeout. Dirty state checks tracked files only to keep large World worktrees responsive. Missing values are explicitly cleared, preventing stale branch information after changing to a non-Git directory.

## Development

```bash
cd ~/dotfiles/herdr/plugins/active-pane-sidebar
python3 -m unittest discover -s tests -v
python3 -m py_compile active_pane_sidebar.py
```

Herdr plugin v1 does not allow plugins to render arbitrary native sidebar UI. This plugin uses the supported metadata-token surface, so row order and styling remain controlled by `config.toml`.
