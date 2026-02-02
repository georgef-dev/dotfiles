# Neovim Key Mappings

## Core Navigation & Editing

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `;` | `:` | Quick command mode |
| `n` | `<C-H>` | `<C-W><C-H>` | Move to left window |
| `n` | `<C-J>` | `<C-W><C-J>` | Move to down window |
| `n` | `<C-K>` | `<C-W><C-K>` | Move to up window |
| `n` | `<C-L>` | `<C-W><C-L>` | Move to right window |
| `n` | `<C-S>` | `:%s/` | Global search and replace |
| `n` | `sp` | `:sp<CR>` | Horizontal split |
| `n` | `vs` | `:vs<CR>` | Vertical split |

## Tmux Navigation (overrides window navigation)

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<C-h>` | `<Cmd>NvimTmuxNavigateLeft<CR>` | Navigate left (tmux aware) |
| `n` | `<C-j>` | `<Cmd>NvimTmuxNavigateDown<CR>` | Navigate down (tmux aware) |
| `n` | `<C-k>` | `<Cmd>NvimTmuxNavigateUp<CR>` | Navigate up (tmux aware) |
| `n` | `<C-l>` | `<Cmd>NvimTmuxNavigateRight<CR>` | Navigate right (tmux aware) |

## Line Movement

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<A-j>` | `:m+1<CR>==` | Move line down |
| `n` | `<A-k>` | `:m-2<CR>==` | Move line up |
| `v` | `<C-J>` | `:m '>+1<CR>gv=gv` | Move selection down |
| `v` | `<C-K>` | `:m '<-2<CR>gv=gv` | Move selection up |

## Buffer & File Management

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>x` | `:bp<bar>sp<bar>bn<bar>bd<CR>` | Close buffer without losing split |
| `n` | `<leader>b` | `<cmd>FzfLua buffers<cr>` | Find buffers |
| `n` | `<leader>;` | `FzfLua buffers (MRU)` | Find in buffers (MRU) |

## Search & Navigation

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<C-p>` | `<cmd>FzfLua files<cr>` | Find files |
| `n` | `<C-f>` | `<cmd>FzfLua live_grep<cr>` | Live grep |
| `n` | `<leader>o` | `<cmd>FzfLua oldfiles<cr>` | Recent files |
| `n` | `<leader>j` | `:cnext<CR>` | Next quickfix item |
| `n` | `<leader>k` | `:cprevious<CR>` | Previous quickfix item |

## Code Formatting

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>f` | `require("conform").format()` | Format buffer (rubocop/stylua) |

## LSP (Language Server Protocol)

### LSP Management

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>li` | `<cmd>LspInfo<cr>` | Show LSP info |
| `n` | `<leader>lr` | `<cmd>LspRestart<cr>` | Restart LSP |
| `n` | `<leader>ls` | `<cmd>LspStart<cr>` | Start LSP |
| `n` | `<leader>lt` | `<cmd>LspStop<cr>` | Stop LSP |
| `n` | `<leader>ll` | `<cmd>LspLog<cr>` | Show LSP log |

### LSP Features (Active when LSP attached)

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `gd` | Go to definition | Jump to definition |
| `n` | `gr` | Go to references | Show references (fzf-lua) |
| `n` | `gD` | Go to declaration | Jump to declaration |
| `n` | `gi` | Go to implementation | Jump to implementation |
| `n` | `<C-o>` | Jump back | Return to previous location |
| `n` | `K` | Hover documentation | Show documentation |
| `n,v` | `<leader>ca` | Code action | Show code actions |
| `n` | `<leader>cd` | Show diagnostics | Show diagnostics float |
| `n` | `[d` | Previous diagnostic | Go to previous diagnostic |
| `n` | `]d` | Next diagnostic | Go to next diagnostic |
| `n` | `<leader>cl` | Diagnostics to loclist | Put diagnostics in location list |
| `i` | `<C-k>` | Signature help | Show function signature |
| `n` | `<leader>cR` | Rename symbol | Rename symbol (LSP) - uses Snacks.input floating window |

## File Tree

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<C-n>` | `<cmd>Neotree filesystem toggle reveal=true reveal_force_cwd<CR>` | Toggle file tree |
| `n` | `<leader>s` | `<cmd>Neotree float git_status<CR>` | Git status tree |

## Git

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>gp` | `:Gitsigns preview_hunk<CR>` | Preview git hunk |
| `n` | `<leader>gt` | `:Gitsigns toggle_current_line_blame<CR>` | Toggle line blame |
| `n` | `<leader>gd` | `<cmd>DiffviewOpen<cr>` | Open diff view (uncommitted changes) |
| `n` | `<leader>gc` | `<cmd>DiffviewClose<cr>` | Close diff view |
| `n` | `<leader>gh` | `<cmd>DiffviewFileHistory %<cr>` | File history |
| `n` | `<leader>pr` | Review PR changes | Opens diffview comparing against Graphite parent branch |

### PR Review Workflow (diffview + Graphite)

1. Checkout PR branch: `gt checkout <branch>` or navigate with `gt up`/`gt down`
2. In Neovim: `<leader>pr` auto-detects parent branch and opens diffview
3. Navigate files with `j`/`k`, `<CR>` to view diff
4. `<leader>gc` to close when done
5. Write review in browser

**In diffview:**

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `j` / `k` | Navigate | Move between files in file panel |
| `n` | `<CR>` | Open diff | Show diff for selected file |
| `n` | `]c` / `[c` | Next/prev hunk | Navigate between diff hunks |
| `n` | `<leader>gc` | Close | Close diffview |

## Testing

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>tf` | `:TestFile -strategy=neovim<cr>` | Test current file |
| `n` | `<leader>tn` | `:TestNearest -strategy=neovim<cr>` | Test nearest |
| `n` | `<leader>tt` | `:TestLast -strategy=neovim<cr>` | Rerun last test |

## AI Assistant

**Note:** CodeCompanion is currently disabled (`enabled = false` in config).

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n,x` | `<leader>aa` | `<cmd>CodeCompanionActions<cr>` | CodeCompanion actions |
| `n,x` | `<leader>ac` | `<cmd>CodeCompanionChat<cr>` | CodeCompanion chat |
| `n,x` | `<leader>ap` | `<cmd>CodeCompanion<cr>` | CodeCompanion prompt |

## UI Enhancements (Snacks.nvim)

Snacks.nvim provides enhanced UI components:
- **Snacks.input** - Replaces `vim.ui.input` with a styled floating window (used by LSP rename)

## Which-key

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>?` | Show buffer local keymaps | Display available keymaps |

## Tmux Integration

**Prefix:** `C-s` (Ctrl-s)

### Pane Navigation (vim-tmux-navigator)

| Key | Action | Description |
|-----|--------|-------------|
| `<C-h>` | Navigate left | Move left (nvim/tmux aware) |
| `<C-j>` | Navigate down | Move down (nvim/tmux aware) |
| `<C-k>` | Navigate up | Move up (nvim/tmux aware) |
| `<C-l>` | Navigate right | Move right (nvim/tmux aware) |
| `M-l` | Clear screen | Send C-l to terminal (clear) |

### Custom Layouts

| Key | Action | Description |
|-----|--------|-------------|
| `C-s q` | 4-pane layout | 2 top (80%), 2 bottom (20%) |
| `C-s a` | 3-pane layout | 2 top (60%), 1 bottom (40%) |
| `C-s v` | 3-pane layout | Left 60%, right split (60%/40%) |

### Built-in Layouts

| Key | Action | Description |
|-----|--------|-------------|
| `C-s Space` | Cycle layouts | Cycle through all layouts |
| `C-s M-1` | Even horizontal | All panes same width, horizontal |
| `C-s M-2` | Even vertical | All panes same height, vertical |
| `C-s M-3` | Main horizontal | Main pane top, others stacked below |
| `C-s M-4` | Main vertical | Main pane left, others stacked right |
| `C-s M-5` | Tiled | All panes equally tiled |

### Pane Management

| Key | Action | Description |
|-----|--------|-------------|
| `C-s h/j/k/l` | Select pane | Move to left/down/up/right pane |
| `C-s {` | Swap with prev | Swap with previous pane |
| `C-s }` | Swap with next | Swap with next pane |
| `C-s !` | Break pane | Move pane to new window |
| `C-s o` | Cycle panes | Rotate through panes |
| `C-s C-arrow` | Resize | Resize pane (hold Ctrl-s, tap arrow) |

### Session Management (tmux-resurrect)

| Key | Action | Description |
|-----|--------|-------------|
| `C-s C-s` | Save session | Save current tmux session |
| `C-s C-r` | Restore session | Restore saved tmux session |
