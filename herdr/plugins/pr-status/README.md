# pr-status

Herdr popup listing your open PRs with check and review status.
Open with the `prefix+u` keybinding or `herdr plugin action invoke georgef.pr-status.open`.
Keys inside the popup: `↑`/`↓` (or `j`/`k`) select, `Enter` opens the PR in a
browser (GitHub URL, or `gs pr open` for Meteorite), `r` refresh, `q`/`Esc` close.

## Sources (work vs home)

The same plugin runs on every machine; sources are per-machine config:

- Default (no config file): `github` via `gh pr list --author @me`.
- Extra sources: one per line in the plugin's config dir.

Enable Meteorite on the work machine only:

```sh
echo meteorite >> "$(herdr plugin config-dir georgef.pr-status)/sources"
```

Meteorite rows come from `gs pr list`.
