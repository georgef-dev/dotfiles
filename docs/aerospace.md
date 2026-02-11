# AeroSpace Tiling Window Manager

## Overview

AeroSpace is a tiling window manager for macOS. It sits at the top of the navigation hierarchy:

| Scope | Modifier | Keys |
|-------|----------|------|
| Within Nvim | (none) | `h/j/k/l` |
| Between Nvim/Tmux panes | `Ctrl` | `h/j/k/l` |
| Between macOS windows | `Alt-Shift` | `h/j/k/l` |

`Alt-Shift` was chosen as the primary modifier to avoid conflicts with Nvim's `Alt-j`/`Alt-k` line movement.

## Setup

Config lives at `aerospace/.config/aerospace/aerospace.toml` and stows to `~/.config/aerospace/aerospace.toml`.

```bash
stow -R aerospace   # from ~/dotfiles
```

Reload config without restarting: `Alt-Shift-;` (enters service mode), then `Alt-Shift-;` again.

## Window Focus

| Key | Action |
|-----|--------|
| `Alt-Shift-h` | Focus window left |
| `Alt-Shift-j` | Focus window down |
| `Alt-Shift-k` | Focus window up |
| `Alt-Shift-l` | Focus window right |

## Move Windows

| Key | Action |
|-----|--------|
| `Alt-Shift-Cmd-h` | Move window left |
| `Alt-Shift-Cmd-j` | Move window down |
| `Alt-Shift-Cmd-k` | Move window up |
| `Alt-Shift-Cmd-l` | Move window right |

## Workspaces

| Key | Action |
|-----|--------|
| `Alt-Shift-1..6` | Switch to workspace 1-6 |
| `Alt-Shift-Cmd-1..6` | Move window to workspace 1-6 (and follow) |

### Default Workspace Assignments

| Workspace | App |
|-----------|-----|
| 1 | Ghostty (terminal) |
| 2 | Chrome (browser) |
| 3 | Slack |
| 4-5 | General use |
| 6 | Spotify |

New windows from these apps are automatically moved to their assigned workspace via `on-window-detected` rules.

## Layout Controls

| Key | Action |
|-----|--------|
| `Alt-Shift-f` | Toggle fullscreen |
| `Alt-Shift-t` | Toggle tile direction (horizontal/vertical) |
| `Alt-Shift-a` | Toggle accordion mode (horizontal/vertical) |
| `Alt-Shift-e` | Balance/equalize window sizes |
| `Alt-Shift-minus` | Resize smaller (`-50`) |
| `Alt-Shift-equal` | Resize larger (`+50`) |

## Layout Presets

Quick keybindings to arrange windows into common layouts.

| Key | Action |
|-----|--------|
| `Alt-Shift-d` | **Dev layout** — focused window ~2/3, other ~1/3 |
| `Alt-Shift-Cmd-d` | **Dev layout (reverse)** — focused window ~1/3, other ~2/3 |
| `Alt-Shift-s` | **Split** — even 50/50 horizontal tiles |
| `Alt-Shift-a` | **Accordion** — stack all windows, show one at a time (good for laptop) |
| `Alt-Shift-f` | **Fullscreen** — focused window takes entire screen |

### Dev layout workflow

1. Put two windows on the same workspace (e.g., move Chrome to workspace 1 with `Alt-Shift-Cmd-2` then `Alt-Shift-1`)
2. Focus the window you want to be larger (e.g., Ghostty)
3. Press `Alt-Shift-d` — it becomes ~2/3 width, the other gets ~1/3

The script auto-adjusts the resize amount based on whether an external monitor is connected. To tweak the ratio, edit `~/.config/aerospace/layouts/dev.sh` and adjust the `DELTA` values.

### Laptop vs external monitor

- **External monitor**: Use `Alt-Shift-d` for dev layout or `Alt-Shift-s` for 50/50
- **Laptop screen**: Use `Alt-Shift-a` (accordion) to show one window at a time, switch between them with `Alt-Shift-h/l`

## Service Mode

Enter service mode with `Alt-Shift-;` for less-common operations.

| Key | Action |
|-----|--------|
| `r` | Reset/flatten layout tree |
| `f` | Toggle floating/tiling |
| `Backspace` | Close all windows but current |
| `Alt-Shift-;` | Reload config |
| `Esc` | Exit service mode |

## Settings

- **Layout:** Tiles (default), auto-orientation
- **Gaps:** 10px inner and outer on all sides
- **Normalization:** Flatten containers and opposite-orientation enabled
- **Mouse:** Moves to focused monitor center on monitor change
- **Start at login:** Enabled
