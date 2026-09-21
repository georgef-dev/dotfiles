# herdr

My [herdr](https://github.com/yuk1ty/herdr) terminal-multiplexer setup: config,
custom plugin, and the Spreader workspace launcher. Tuned to mirror my tmux
muscle memory (`Ctrl+s` prefix, tmux-style keys, Rose Pine).

Launch herdr **outside** tmux — an outer tmux would swallow the `Ctrl+s` prefix.

## Layout

```
herdr/
  .config/herdr/config.toml          # stow target -> ~/.config/herdr/config.toml
  plugins/active-pane-sidebar/        # custom plugin (registered by absolute path)
  spreader/                           # Ctrl+s v workspace launcher
    apply.sh                          #   popup wrapper (prompts + layout)
    config.yaml                       #   V-layout Spreader template
  lazygit/                            # Ctrl+s g lazygit popup
    open.sh                           #   cd's into the focused pane's cwd, execs lazygit
  .stow-local-ignore                  # keeps plugins/ + spreader/ + lazygit/ out of $HOME
```

Only `.config/` is symlinked into `$HOME`. `plugins/`, `spreader/`, and
`lazygit/` are repo assets that herdr references by their absolute
`~/dotfiles/herdr/...` path (see `plugins.json`, the `config.toml` popup
commands, and `apply.sh`/`open.sh`), so they must not be stowed —
`.stow-local-ignore` excludes them.

## Install

```bash
hms             # links all three plugins and wires spreader's config
stow herdr      # -> ~/.config/herdr/config.toml
```

`nix/home/programs/herdr.nix` owns the plugin wiring. There is nothing to
install by hand:

| Plugin | Source |
| --- | --- |
| `vim-herdr-navigation` | pinned in `nix/pkgs/`, linked from the store |
| `herdr-spreader` | pinned in `nix/pkgs/`, binary prebuilt by nix |
| `georgef.active-pane-sidebar` | linked from this repo, so edits are live |

Do **not** use `herdr plugin install`: it clones into
`~/.config/herdr/plugins/`, which is a stow symlink into this repo, so the
plugin's source and its `.git` land in the working tree.

The zsh `precmd` hook feeding the sidebar lives in `nix/home/programs/zsh/`.

## What's here

### config.toml
tmux-style keys under the `Ctrl+s` prefix, Rose Pine, mouse + copy-on-select,
`alt+l` clear, no pane gaps, secure `pane_history=false`. Sidebar rows render
the active pane's directory / worktree / branch / git-state via the sidebar
plugin's metadata tokens. `Ctrl+h/j/k/l` route through `vim-herdr-navigation`;
`Ctrl+s v` opens the Spreader popup; `Ctrl+s g` opens lazygit over the focused
pane's directory.

### plugins/active-pane-sidebar (custom)
Python-stdlib plugin. On pane/workspace focus events it reports `active_dir`,
`worktree`, `branch`, `git_state`, and `pane_context` tokens via
`herdr workspace report-metadata`, driving the sidebar rows. Prefers a non-transient
`foreground_cwd` so resumed agents report the right worktree. Tests in `tests/`.

### spreader (custom `Ctrl+s v` launcher)
Prompts for a workspace name, a `dev cd` target, and a worktree, then builds a
V layout (Pi/agent left, editor + shell right). Target and worktree prompts use
`fzf` (arrow keys, fuzzy filter, type-to-create, Esc to skip) with a numbered-menu
fallback when `fzf` is absent. New worktrees are created once in the wrapper via
`dev tree add` (never per pane); each pane runs an idempotent `dev tree switch`.
Pane command order is `dev cd -> dev tree -> apps`. See `spreader/README.md`.

macOS AMFI SIGKILLs unsigned locally-built Rust binaries. `nix/pkgs/herdr-spreader.nix`
builds the binary in the trusted Nix store and lays it out at
`target/release/herdr-spreader` where the manifest's action expects it, which
is what `fix-macos-build.sh` used to do by hand.

### lazygit (custom `Ctrl+s g` launcher)
`lazygit/open.sh` reads `$HERDR_ACTIVE_PANE_CWD` (falling back to `$PWD`),
aborts with a "Not a git repo" message when the focused pane isn't inside a
work tree, otherwise `cd`s there and execs `lazygit`. The popup is 90% x 90%.
Requires `lazygit` on `$PATH` (Homebrew: `brew install lazygit`).

## Related packages
- `nix/home/programs/zsh/default.nix` — precmd hook feeding the sidebar plugin.
- `nvim/.config/nvim/lua/plugins/nvim-tmux-navigation.lua` — seamless nvim/herdr/tmux navigation.
- `nvim/.config/nvim/lua/plugins/test.lua` — vim-test `herdr` strategy (splits + reuses its own pane).

## Not tracked
herdr's runtime files stay out of the repo: sockets, logs, `session.json`,
`plugins.json`, and the downloaded third-party plugins under
`~/.config/herdr/plugins/github/`.
