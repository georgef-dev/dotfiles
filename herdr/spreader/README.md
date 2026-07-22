# Herdr spreader layout

Declarative [herdr-spreader](https://github.com/yuk1ty/herdr-spreader) config for a generic V-shaped dev workspace.

## Layout

`config.yaml` creates one workspace from the **invocation cwd** (no `root:` override):

| Piece | Value |
| --- | --- |
| Workspace | `dev` |
| Tab | `work` |
| Pane 1 | `nvim`, focused |
| Pane 2 | split **right**, ratio `0.6`, leaving Neovim at 60% width |
| Pane 3 | split **down** from pane 2, ratio `0.7`, leaving the lower pane at 30% height |

```
+------------------+------------+
|                  |   shell    |
|      nvim        +------------+
|     (focus)      |   shell    |
+------------------+------------+
```

Spreader chains splits from the previous pane, so the third pane becomes the bottom of the right column.

## Install and apply

```bash
herdr plugin install yuk1ty/herdr-spreader --yes
config_dir=$(herdr plugin config-dir herdr-spreader)
ln -sfn ~/dotfiles/herdr/spreader/config.yaml "$config_dir/config.yaml"
```

On this managed macOS machine, locally built unsigned Rust binaries are blocked by AMFI. Build Spreader into the trusted Nix store and link the plugin to it:

```bash
~/dotfiles/herdr/spreader/fix-macos-build.sh
```

Apply from the active pane's project directory:

```bash
herdr plugin action invoke herdr-spreader.apply
```

`Ctrl+s v` opens a small Herdr popup, proposes the current World worktree (or directory) as the default workspace name, and creates the layout from the calling pane's directory. The wrapper writes a temporary YAML file, so the committed `dev` template remains unchanged.

It then asks for the name, a `dev cd` target, and a worktree.

When `fzf` is installed (the normal case), the target and worktree prompts are
`fzf` pickers: arrow keys to move, type to fuzzy-filter, Enter to accept. Typing
a value that matches nothing and pressing Enter accepts what you typed (so a new
worktree name or an ad-hoc `dev cd` target needs no separate "other" option),
and Esc skips the prompt (keep current directory / current tree). The go-tos
seeded into the target picker are `shopify-playground/georgef`,
`shopify/second-brain`, `shopify`, and `admin-web`; the worktree picker is seeded
from `dev tree list`.

Without `fzf`, both prompts fall back to a numbered menu:

```text
Workspace name [po-public-api]: PO API
dev cd target:
   1) shopify-playground/georgef
   2) shopify/second-brain
   3) shopify
   4) admin-web
   5) none (stay in this directory)
   6) other (type a target)
Select [5]: 3
Worktree:
   1) be-reviews
   2) not-shipped
   3) po-public-api
   4) pr-review
   5) current (stay in this tree)
   6) other (type a name)
Select [5]: 2
```

Press Enter on the first prompt to accept the default name, and Enter on the menu to keep the current tree.

## Worktree selection

The menu lists every worktree from `dev tree list`, then two trailing options:

- **current** keeps the current worktree (also the default when you press Enter).
- **other** prompts for a name you type, which may be an existing id or a brand-new one.

Resolution:

- An existing id makes every pane run `dev tree switch <id>`, which lands in the same zone path inside that tree.
- A new name is created once with `dev tree add <name>` inside the popup (not per pane, to avoid a duplicate-add race), then every pane runs `dev tree switch <name>`.

## dev cd target

The menu lists the usual go-tos (`shopify-playground/georgef`, `shopify/second-brain`, `shopify`, `admin-web`), then `none` (the Enter default) and `other` for a typed target. Any value is passed straight to `dev cd`, which fuzzy-matches it. When a target is chosen, every pane runs `dev cd <target>`, so all panes enter that project with shadowenv loaded.

Both prefixes compose per pane, for example:

```text
dev tree switch not-shipped && dev cd shopify && nvim
```

The empty bottom pane runs just the prefix. The committed template is never modified; the wrapper mutates a temporary copy with system Ruby under a clean environment.

To preview without touching the session:

```bash
plugin_root=$(herdr plugin list --json | jq -r '.result.plugins[] | select(.plugin_id == "herdr-spreader") | .plugin_root')
"$plugin_root/target/release/herdr-spreader" \
  apply --file ~/dotfiles/herdr/spreader/config.yaml --dry-run
```

## vim-test Herdr strategy

Neovim plugin: `nvim/.config/nvim/lua/plugins/test.lua`.

- Strategy name: `herdr` (default `g:test#strategy`)
- First run requires `$HERDR_PANE_ID`, splits **that** Neovim pane down at ratio `0.7` (new test pane gets 30%) with `--cwd` = `getcwd()` and `--no-focus`
- Stores only `.result.pane.pane_id` in the current Neovim process
- Waits for the new shell prompt before its first command, avoiding lost input during zsh/wish startup
- Runs the test command via `herdr pane run <id> <cmd>`
- Later runs: `pane get` the stored id only → `send-keys ctrl+c` → `pane run`
- If the stored pane is gone, clears state and creates a new split (never searches other panes)
- Uses `vim.system` argv lists; binary is `$HERDR_BIN_PATH` when executable, else `herdr`
- `:HerdrTestPaneReset` forgets the stored id without closing the pane

Keymaps (unchanged):

| Key | Command |
| --- | --- |
| `<leader>tf` | `:TestFile` |
| `<leader>tn` | `:TestNearest` |
| `<leader>tt` | `:TestLast` |
