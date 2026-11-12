# Using chezmoi on the Omarchy Dell

The Dell is the first migrated host. Chezmoi manages a small CLI baseline and
Git/Bash preferences; Omarchy still manages its desktop, terminal, Neovim, and
Herdr configuration. The personal Mac, VM, and infra-nuc retain Home Manager and
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
mapping on Omarchy. Homebrew and apt mappings are preparation, not tested support.
`nix` is project infrastructure; its Mac installation path remains a later choice.

When the rendered package list changes, the before-install script calls
`omarchy pkg add` to install missing packages. It does not remove software or
upgrade the system. A manually removed package can be restored with
`omarchy pkg add <package>`; an unchanged apply does not rerun the installer.
Continue normal Omarchy updates through `omarchy update`.

Omarchy also declares GitHub CLI through mise. A user override disables mise management
for `gh`, so the installed Arch package supplies it while other Omarchy mise
integrations continue to work. No existing mise installations are deleted.

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
shellcheck chezmoi/dot_bashrc chezmoi/dot_config/dotfiles/bash.sh
chezmoi verify
```

The integration check renders all profiles, checks script syntax, verifies
non-migrated profile guards, and on Omarchy applies twice to a temporary HOME with
a package-command stub. It never installs packages or changes the real HOME.

Before the Dell's first apply, affected files were backed up under
`~/.local/state/dotfiles/backups/20261112T023556Z/`. The accompanying
`previously-absent.txt` lists files that did not exist. To recover, restore backed
up files to their original HOME paths, remove only newly created files identified
in that list (also `.config/mise/config.toml`, added just afterward), and open a
new terminal. Stop applying this source until its desired state is corrected.
Installed native packages and the Nix socket are separate from file recovery;
no package removal is required to restore the previous shell and Git behavior.
