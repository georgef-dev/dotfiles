                     __
                     / _|
                __ _| |_
               / _` |  _|
              | (_| | |
               \__, |_|
                __/ |
               |___/

# Setup

```bash
git clone https://github.com/georgef-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./helpers/bootstrap
```

On a bare Debian VM that is everything: it installs apt prerequisites,
installs Nix, activates Home Manager, sets the login shell, and stows the
configs Home Manager does not own.

On macOS it does **nothing** unless you pass `--host mac`. Migrating the Mac
is opt-in:

```bash
./helpers/bootstrap --host mac --dry-run   # read the plan
./helpers/bootstrap --host mac             # then run it from a SECOND terminal
```

# Nix / Home Manager

Packages and most dotfiles are declared in a flake and pinned by
`flake.lock`, so both machines get identical versions.

```bash
home-manager switch -b bak --flake ~/dotfiles#gf@mac        # or #gf@debian-vm
nix flake check                                             # validate changes
nix flake update && home-manager switch --flake ...         # upgrade everything
home-manager generations                                    # roll back
```

`-b bak` matters: without it Home Manager refuses to overwrite a file that
already exists. With it, the old file is renamed `.bak`.

Layout:

- `nix/home/core.nix` — portable baseline, safe on any host
- `nix/home/extras/` — opt-in groups (`infra`, `containers`, `media`)
- `nix/home/{darwin,linux}.nix` — platform specifics
- `nix/home/programs/` — zsh, git, tmux, direnv
- `nix/devshells/` — per-project toolchains

# Per-project runtimes

There are no version managers. Each project declares its own toolchain:

```bash
echo 'use flake ~/dotfiles#node' > .envrc && direnv allow
```

Available shells: `default` (python3/node/go), `node`, `python`, `ruby`,
`rust`. A small fallback set is on `PATH` ambiently for ad-hoc scripts.

# Homebrew

macOS only, and only for GUI casks and `mas`. Every CLI tool comes from Nix.

# iTerm

- Import preferences from local folder
- Import profile JSON

# Stow

Configs Home Manager does not own are still managed with
[GNU Stow](https://www.gnu.org/software/stow/): `nvim` (it pins its own
plugins via `lazy-lock.json`), plus the macOS GUI apps `ghostty` and
`joplin`. Each folder is a package (except `manual_config` and `helpers`).

For each desired config, run `stow <package>`.

Example: `stow nvim` will create the sumlinks for `$HOME/.config/nvim`.
# nvim

Open nvim and run: `:Lazy`

# Python

Install needed Python versions using `pyenv`.

- 3.10.0 -> `pyenv install 3.10.0`

# Setup Github SSH Key

```bash
# SEE: https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# SEE: https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
```

# Install GPG and Keybase keys

```bash
# SEE: https://github.com/pstadler/keybase-gpg-github
# SEE: https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
```

```bash
keybase login
chmod 700 ~/.gnupg
keybase pgp list
keybase pgp export -q <ID_FROM_ABOVE> | gpg --import
keybase pgp export -q <ID_FROM_ABOVE> --secret | gpg --allow-secret-key-import --import
```
