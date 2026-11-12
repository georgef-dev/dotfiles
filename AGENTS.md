# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles: one CLI environment across macOS and Linux, driven by a Nix flake + Home Manager, with GNU Stow for the few configs Home Manager does not own. The README and `docs/using-nix-home-manager.md` are the full user docs; read the latter before non-trivial Nix changes.

## Commands

```bash
nix flake check                 # validate a change (do this before hms)
hms                             # rebuild + activate this host (zsh function in nix/home/programs/zsh/default.nix)
hms --show-trace                # extra flags pass through to home-manager switch
./helpers/doctor                # read-only health check; exit code = failure count
./helpers/sync                  # report drift after changing a host's bundles; --apply to fix
./helpers/bootstrap --host <h> --dry-run   # bootstrap plan; --host is mandatory
nix flake update [nixpkgs|home-manager]    # update inputs (separately: they fail differently)

# herdr sidebar plugin tests (stdlib unittest, no deps)
python3 -m unittest discover -s herdr/plugins/active-pane-sidebar/tests
python3 -m unittest herdr/plugins/active-pane-sidebar/tests/test_active_pane_sidebar.py -k <name>
```

The flake reads the working tree, but **new files must be `git add`ed** or Nix cannot see them ("file not found").

## Architecture

**Hosts × bundles.** `flake.nix` defines `hosts` (mac, vm-dev-01, infra-nuc), each = `nix/home/core.nix` (always) + a platform module (`darwin.nix` / `linux.nix` / `server.nix`, Linux ones importing `linux-base.nix`) + a list of bundles from `nix/home/extras/` (`dev ai infra containers media terminal`). Outputs are `homeConfigurations."gf@<host>"`. Bundles may import modules from `nix/home/programs/`. Name bundles by purpose, not tool.

**The host table is duplicated in three places that must stay in sync:**
1. `hosts` in `flake.nix`
2. `HOST_TABLE` in `helpers/lib/host.sh` (used by bootstrap, doctor, sync)
3. the `case` in the `hms()` function in `nix/home/programs/zsh/default.nix`

Adding a host or changing a host's bundles means editing all relevant ones. The mac matches on `uname` (Darwin) rather than hostname because macOS rewrites its hostname.

**Stow packages** (`nvim`, `herdr`, `ghostty`, `joplin`) are top-level dirs mirroring `$HOME`. Which ones a host gets is derived from its bundles in `host_stow_packages` in `helpers/lib/host.sh` — teach that function about any new bundle→stow mapping so bootstrap and sync agree. Don't tell the user to `stow` by hand; bootstrap/sync do it.

**herdr** is stowed with `--no-folding` so `~/.config/herdr` is a real dir and herdr's runtime state (logs, `session.json`, `plugins.json`, sockets) never lands in the repo. Only `herdr/.config/` is stowed; `plugins/`, `spreader/`, `lazygit/` are referenced by absolute `~/dotfiles/herdr/...` paths and excluded via `.stow-local-ignore`. Plugin registration is done by the activation script in `nix/home/programs/herdr.nix` — never `herdr plugin install`. See `herdr/README.md`.

**Packages not in nixpkgs** live in `nix/pkgs/` (pinned to a commit, pulled in with `callPackage`). They pin their own versions/hashes, so `nix flake update` doesn't touch them; bump recipes are in each file's header.

**Per-project toolchains** come from `nix/devshells/default.nix` via `use flake ~/dotfiles#<shell>` in `.envrc`. No version managers. Give each devShell a `name` — the p10k prompt displays it.

## Conventions and gotchas

- Every CLI tool comes from Nix. Homebrew (`brew/.Brewfile`) is macOS GUI casks and `mas` only.
- Daemon+CLI pairs (docker daemon, tailscale) are deliberately not in Nix; Home Manager can't own system units.
- Config Home Manager writes is read-only store symlinks; tools that write their own config (e.g. `~/.docker/config.json`, `plugins.json`) are intentionally left unmanaged.
- `nix/home/core.nix` must stay portable and safe on any host, including a work machine.
- `reference/` holds retired configs imported by nothing — don't wire it back in.
- nvim plugins are pinned in `nvim/.config/nvim/lazy-lock.json`; commit it after `:Lazy update`.
- Commit signing is per-machine SSH keys. GPG key `020388768FEBD380` is compromised and revoked — never reference or re-import it. Never commit key material (see `.gitignore`).
- p10k config is `nix/home/programs/zsh/p10k.zsh`; regenerate with `p10k configure` and copy `~/.p10k.zsh` back.
