# Using chezmoi on the Omarchy Dell

The Dell is the first migrated host. Chezmoi manages a small CLI baseline and
Git/Bash preferences and Herdr configuration. Omarchy still manages its desktop,
terminal, and Neovim configuration. The personal Mac, VM, and infra-nuc retain Home Manager and
Stow for now. Their existing bootstrap and `hms` commands are unchanged.

## Source and local settings

The repository's `.chezmoiroot` selects `chezmoi/` as the deployable source.
Documentation, legacy Stow directories, and Nix modules are not copied into HOME.
The active checkout on this Dell is `~/Work/dotfiles`, branch
`plan/chezmoi-migration`. `chezmoi source-path` shows its source directory.

Machine settings live outside Git in `~/.config/chezmoi/chezmoi.toml`: profile,
Git name/email, and an optional SSH signing public-key path. Initialization prompts
for these settings rather than inferring identity from the operating system.
An empty signing-key setting leaves signing disabled; test a key before enabling
it. `helpers/allowed-signers` can maintain local verification identities once Git
identity is configured. Never track private keys or credentials.

Only `omarchy` is ready to apply. `personal-mac`, `dev-vm`, and `work-mac` currently
ignore managed configuration and fail before installing packages. These guards
are intentional until those machines have been assessed and migrated.

## Everyday commands

```bash
chezmoi diff                  # preview files and pending scripts
chezmoi apply --dry-run --verbose
chezmoi apply
chezmoi verify                # compare managed files with their desired state
chezmoi edit ~/.config/git/config
chezmoi edit ~/.config/dotfiles/bash.sh
```

Edit the managed source, preview, and apply. Direct edits to deployed files do not
automatically update the source. Commit and push changes from the repository as
usual. `chezmoi update` pulls and applies changes from the current branch; use it
only when ready to apply that branch. No automatic commits or pushes are enabled.
Open a new terminal to load shell changes.

## Packages and upgrades

`chezmoi/.chezmoidata/packages.yaml` is the authoritative inventory for this first
CLI slice. Each tool records native package names; the installer uses the Arch
mapping on Omarchy. Homebrew and apt mappings are preparation, not tested support. Entries marked
`source: aur` use `omarchy pkg aur add`; unmarked entries use repository packages.
AUR recipe changes should be reviewed during normal package upgrades.
`nix` is project infrastructure; its Mac installation path remains a later choice.

When the rendered package list changes, the before-install script calls
`omarchy pkg add` to install missing packages. It does not remove software or
upgrade the system. A manually removed package can be restored with
`omarchy pkg add <package>` for repository packages, or
`omarchy pkg aur add <package>` for AUR packages; an unchanged apply does not
rerun the installer.
Continue normal Omarchy updates through `omarchy update`.

Omarchy also declares GitHub CLI through mise. A user override disables mise management
for `gh`, so the installed Arch package supplies it while other Omarchy mise
integrations continue to work. Claude Code, Codex, and OpenCode retain their
Omarchy mise providers. No existing mise installations are deleted.

## Adopting this branch on another Omarchy installation

Install chezmoi through `omarchy pkg add chezmoi`. Check out this branch, then run
from the checkout root:

```bash
chezmoi --source "$PWD" init
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

Choose the `omarchy` profile and preserve the machine's Git identity. Inspect and
back up existing target files first, especially `.bashrc`, Git configuration, and
any existing mise/Nix user config. This initial source is based on the Dell's
starting defaults and is not an automatic merge of arbitrary local preferences.
Do not apply over Home Manager or Stow ownership without first transferring it.

## Project dependencies

The native Arch Nix package supplies Nix. Its daemon is enabled through
`nix-daemon.socket`; on a new installation enable it once after package installation:

```bash
sudo systemctl enable --now nix-daemon.socket
nix store info
```

Chezmoi enables flakes in the user Nix configuration. Home Manager is not installed
on the Dell and there are no global Nix profiles to activate. Existing devShells
remain in the root flake:

```bash
cd ~/Work/dotfiles
nix develop .#default
```

For a project, use an absolute reference to your actual checkout in `.envrc`, for
example `use flake /home/georgeferreira/Work/dotfiles#node`, then run `direnv allow`
in that project. The Bash hook loads direnv after Omarchy initializes its shell.
The existing `~/dotfiles` references on legacy hosts remain valid there.

## Checks and recovery

```bash
python3 tests/check-chezmoi.py
python3 -m unittest discover -s tests -p test_herdr_workspace.py
shellcheck chezmoi/dot_bashrc
chezmoi execute-template < chezmoi/dot_config/dotfiles/bash.sh.tmpl | shellcheck -s bash -
chezmoi verify
```

The integration check renders all profiles, checks script syntax, verifies
non-migrated profile guards, and on Omarchy applies twice to a temporary HOME with
package/plugin command stubs and a local archive fixture. It never downloads
third-party code, installs packages, or changes the real HOME.

Before the Dell's first apply, affected files were backed up under
`~/.local/state/dotfiles/backups/20261112T023556Z/`. The accompanying
`previously-absent.txt` lists files that did not exist. To recover, restore backed
up files to their original HOME paths, remove only newly created files identified
in that list (also `.config/mise/config.toml`, added just afterward), and open a
new terminal. Stop applying this source until its desired state is corrected.
Installed native packages and the Nix socket are separate from file recovery;
no package removal is required to restore the previous shell and Git behavior.

## Herdr on the Dell

Chezmoi renders `herdr/.config/herdr/config.toml` into the real
`~/.config/herdr/config.toml`, substituting checkout-relative popup paths. The
legacy Stow source stays in place for the Mac and VM. Only the config file is
managed: logs, sockets, sessions, and `plugins.json` remain Herdr-owned and outside
Git. A before-apply check refuses a symlinked Herdr directory.

Your bindings now use Ctrl+S as the prefix:

| Keys | Action |
| --- | --- |
| Ctrl+S, then `?` | Active keybinding help |
| Ctrl+S, then `%` / `"` | Split right / down |
| Ctrl+S, then `h/j/k/l` | Focus a neighboring pane |
| Ctrl+S, then `b` / `w` | Toggle sidebar / select workspace |
| Ctrl+S, then `v` | Name a workspace; Neovim left, two shells right |
| Ctrl+S, then `g` | Lazygit popup in the focused pane's directory |
| Ctrl+S, then `Alt+g` | Built-in pane search |
| Ctrl+S, then `u` | GitHub PR status popup |

Ctrl+H/J/K/L uses the pinned navigation plugin: shells change Herdr panes and
Neovim receives its usual window-navigation keys. Leaving Neovim at a split edge
still requires the prefix bindings because its configuration is intentionally
unchanged. The workspace launcher uses native Herdr commands in the invoking
pane's directory. It waits for the editor shell to start and closes only its new
workspace if setup fails. The old Shopify Spreader wrapper remains for legacy
hosts; the Dell needs no Spreader build or Shopify dev tooling.

The navigation archive is pinned and checksum-verified, then deployed under
`~/.local/share/dotfiles/herdr/`. The two personal Python plugins are linked from
this checkout. The after-apply script registers these sources with Herdr, so no
plugin registry or downloaded source enters the repository. The Bash prompt
refreshes the sidebar's directory/worktree/Git metadata inside Herdr panes.

`chezmoi diff` always displays the directory safety-check script. To see file-only
drift, use `chezmoi diff --exclude scripts`. Plugin registration runs only when
its rendered script changes. No server stop or restart is part of apply.

Check with `herdr config check`, `herdr plugin list`, and
`herdr plugin action list`. If an existing client hasn't picked up the new
settings, reload config from Herdr's menu or run `herdr server reload-config`
inside a Herdr pane. Keep the server and its existing processes running.

## Minidev

Minidev is retained as an editable checkout, outside chezmoi ownership. On a new
personal machine, clone it once before opening a fresh terminal:

```bash
git clone https://github.com/georgef-dev/minidev.git ~/src/github.com/georgef-dev/minidev
```

The personal Bash fragment sources that checkout's `dev.sh` when present. Native
Ruby is included in the package inventory to run minidev outside project shells;
project-specific Ruby versions still come from project environments. Update
minidev through its own checkout. Chezmoi does not overwrite or update it.

On this Dell, open a new terminal or run
`source ~/.config/dotfiles/bash.sh` to load the `dev` shell function.

## Containers on the Dell

Docker uses Omarchy's existing socket activation and authorization model. The
socket is enabled for boot; an inactive daemon can be normal before first use.
Run `sudo docker ...` or `sudo lazydocker` from a terminal. No docker-group access
was granted during migration. Docker CLI, Compose, Buildx, and lazydocker are
selected across personal machines; the Mac uses Colima as its Docker backend.
