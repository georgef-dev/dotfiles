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
    fix-macos-build.sh                #   builds the Rust binary in the Nix store
  .stow-local-ignore                  # keeps plugins/ + spreader/ out of $HOME
```

Only `.config/` is symlinked into `$HOME`. `plugins/` and `spreader/` are repo
assets that herdr references by their absolute `~/dotfiles/herdr/...` path (see
`plugins.json`, the `config.toml` popup command, and `apply.sh`), so they must
not be stowed — `.stow-local-ignore` excludes them.

## Install

```bash
# 1. Config
stow herdr                      # -> ~/.config/herdr/config.toml

# 2. Custom sidebar plugin (registers the absolute dotfiles path)
herdr plugin install ~/dotfiles/herdr/plugins/active-pane-sidebar
# zsh precmd hook that feeds it lives in zsh/.zshrc-functions

# 3. Spreader base plugin + config + macOS-safe binary
herdr plugin install yuk1ty/herdr-spreader          # or the current source
ln -sf ~/dotfiles/herdr/spreader/config.yaml \
       "$(herdr plugin config-dir herdr-spreader)/config.yaml"
~/dotfiles/herdr/spreader/fix-macos-build.sh        # builds + GC-roots the binary

# 4. Third-party navigation plugin (for Ctrl+h/j/k/l with Neovim)
herdr plugin install <vim-herdr-navigation source>

herdr server reload-config
```

## What's here

### config.toml
tmux-style keys under the `Ctrl+s` prefix, Rose Pine, mouse + copy-on-select,
`alt+l` clear, no pane gaps, secure `pane_history=false`. Sidebar rows render
the active pane's directory / worktree / branch / git-state via the sidebar
plugin's metadata tokens. `Ctrl+h/k/l` route through `vim-herdr-navigation`;
`Ctrl+s v` opens the Spreader popup.

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

macOS AMFI SIGKILLs unsigned locally-built Rust binaries, so `fix-macos-build.sh`
builds the Spreader binary inside the trusted Nix store and GC-roots it; the
plugin config dir symlinks `nix-build` at that store path.

## Related packages
- `zsh/.zshrc-functions` — precmd hook feeding the sidebar plugin.
- `nvim/.config/nvim/lua/plugins/nvim-tmux-navigation.lua` — seamless nvim/herdr/tmux navigation.
- `nvim/.config/nvim/lua/plugins/test.lua` — vim-test `herdr` strategy (splits + reuses its own pane).

## Not tracked
herdr's runtime files stay out of the repo: sockets, logs, `session.json`,
`plugins.json`, and the downloaded third-party plugins under
`~/.config/herdr/plugins/github/`.
