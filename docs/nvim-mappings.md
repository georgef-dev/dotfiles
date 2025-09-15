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
| `n` | `<leader>b` | `<cmd>Telescope buffers<cr>` | Find buffers |
| `n` | `<leader>;` | Function | Find in buffers (MRU) |

## Search & Navigation

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<C-p>` | `<cmd>Telescope find_files<cr>` | Find files |
| `n` | `<C-f>` | `<cmd>Telescope live_grep<cr>` | Live grep |
| `n` | `<leader>o` | `<cmd>Telescope oldfiles<cr>` | Recent files |
| `n` | `<leader>j` | `:cnext<CR>` | Next quickfix item |
| `n` | `<leader>k` | `:cprevious<CR>` | Previous quickfix item |

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

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n,x` | `<leader>aa` | `<cmd>CodeCompanionActions<cr>` | CodeCompanion actions |
| `n,x` | `<leader>ac` | `<cmd>CodeCompanionChat<cr>` | CodeCompanion chat |
| `n,x` | `<leader>ap` | `<cmd>CodeCompanion<cr>` | CodeCompanion prompt |

## Copilot

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `i` | `<C-j>` | Accept Copilot suggestion | Accept completion |

## Which-key

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| `n` | `<leader>?` | Show buffer local keymaps | Display available keymaps |

## Octo (GitHub Integration)

The Octo plugin provides extensive GitHub integration with many keymaps for issues, pull requests, and reviews. Key bindings use `<localleader>` prefix and include:

- Issue management: `<localleader>ic` (close), `<localleader>io` (reopen), `<localleader>il` (list)
- PR operations: `<localleader>po` (checkout), `<localleader>pm` (merge), `<localleader>pd` (show diff)
- Comments: `<localleader>ca` (add), `<localleader>cd` (delete), `]c`/`[c` (navigate)
- Reactions: `<localleader>r+` (👍), `<localleader>r-` (👎), `<localleader>rh` (❤️), etc.
- Reviews: `<localleader>vs` (start/submit), `<localleader>vr` (resume), `<localleader>rt` (resolve thread)