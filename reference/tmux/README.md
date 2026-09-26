# tmux (retired)

Retired in favour of [herdr](../../herdr/). Kept for reference only — nothing
imports these files, so tmux is neither installed nor configured on any host.

`default.nix` was `nix/home/programs/tmux/`, a Home Manager module: `Ctrl+s`
prefix, vi keys, Rose Pine, mouse on, and a `git-status.sh` wrapped as a
`writeShellApplication` feeding the status line. The herdr config in
`herdr/.config/herdr/config.toml` was written to mirror these keybindings, so
this is the record of what it was mirroring.

## To bring it back

```nix
# nix/home/extras/terminal.nix
imports = [
  ../../../reference/tmux   # or move it back under nix/home/programs/
  ../programs/herdr.nix
];
```

macOS also needs `reattach-to-user-namespace` for tmux's clipboard; it was
removed from `terminal.nix` along with tmux.

The older GNU Stow version of this config (`tmux/.tmux.conf`) was retired
earlier, in Phase 4, and is in git history.
