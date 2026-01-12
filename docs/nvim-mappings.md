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
| `n` | `<leader>cR` | Rename symbol | Rename symbol (LSP) |

## File Tree

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<C-n>` | `<cmd>Neotree filesystem toggle reveal=true reveal_force_cwd<CR>` | Toggle file tree |
| `n` | `<leader>s` | `<cmd>Neotree float git_status<CR>` | Git status tree |

## Git

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>gp` | `:Gitsigns preview_hunk<CR>` | Preview git hunk |

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

## Which-key

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>?` | Show buffer local keymaps | Display available keymaps |

## Octo (GitHub Integration)

### Opening PRs

| Command | Description |
|---------|-------------|
| `:Octo pr list` | List PRs with fzf picker |
| `:Octo pr <number>` | Open specific PR by number |
| `:Octo pr url <url>` | Open PR by URL |

### PR Review Workflow

**Starting a review:**
1. `:Octo pr <number>` - Open the PR
2. `<localleader>vs` - Start review (opens diff view with file panel)

**In diff view:**

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `]q` / `[q` | Next/prev file | Navigate changed files |
| `n` | `]t` / `[t` | Next/prev thread | Navigate comment threads |
| `n` | `<localleader>ca` | Add comment | Add review comment (works in visual mode) |
| `n,x` | `<localleader>sa` | Add suggestion | Add code suggestion |
| `n` | `<localleader>e` | Focus files | Focus file panel |
| `n` | `<localleader>b` | Toggle files | Show/hide file panel |
| `n` | `<localleader><space>` | Toggle viewed | Mark file as viewed |
| `n` | `gf` | Go to file | Open file in local filesystem |
| `n` | `]c` / `[c` | Next/prev comment | Navigate comments in thread |
| `n` | `<localleader>rt` | Resolve thread | Resolve PR thread |
| `n` | `<localleader>rT` | Unresolve thread | Unresolve PR thread |

**In file panel:**

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `j` / `k` | Navigate | Move between files |
| `n` | `<CR>` | Open diff | Show diff for selected file |
| `n` | `R` | Refresh | Refresh file list |

**Submitting review:**

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<localleader>vs` | Submit review | Opens submit window |

**In submit window:**

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n,i` | `<C-a>` | Approve | Approve review |
| `n,i` | `<C-m>` | Comment | Comment only |
| `n,i` | `<C-r>` | Request changes | Request changes |
| `n,i` | `<C-c>` | Close | Close without submitting |

### Issue Management

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<localleader>ic` | Close issue/PR | Close issue or PR |
| `n` | `<localleader>io` | Reopen issue/PR | Reopen issue or PR |
| `n` | `<localleader>il` | List issues | List open issues |

### PR Operations

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<localleader>pm` | Merge PR | Merge commit PR |
| `n` | `<localleader>psm` | Squash & merge | Squash and merge PR |
| `n` | `<localleader>prm` | Rebase & merge | Rebase and merge PR |
| `n` | `<localleader>pc` | List commits | List PR commits |
| `n` | `<localleader>pf` | List files | List PR changed files |
| `n` | `<localleader>pd` | Show diff | Show PR diff |

### Comments & Reactions

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<localleader>ca` | Add comment | Add comment |
| `n` | `<localleader>cd` | Delete comment | Delete comment |
| `n` | `]c` / `[c` | Navigate comments | Next/previous comment |
| `n` | `<localleader>r+` | 👍 | Add/remove thumbs up |
| `n` | `<localleader>r-` | 👎 | Add/remove thumbs down |
| `n` | `<localleader>rh` | ❤️ | Add/remove heart |
| `n` | `<localleader>re` | 👀 | Add/remove eyes |
| `n` | `<localleader>rr` | 🚀 | Add/remove rocket |
| `n` | `<localleader>rp` | 🎉 | Add/remove party |
| `n` | `<localleader>rl` | 😄 | Add/remove laugh |
| `n` | `<localleader>rc` | 😕 | Add/remove confused |

### Browser Integration

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<C-b>` | Open in browser | Open PR/issue in browser |
| `n` | `<C-y>` | Copy URL | Copy URL to clipboard |
| `n` | `<C-r>` | Reload | Reload PR/issue |

---

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
