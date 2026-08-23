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
home-manager switch -b bak --flake ~/dotfiles#gf@mac        # or #gf@vm-dev-01
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

# GPG signing key

`commit.gpgsign` is on, so **every commit fails until the signing key is
imported**. The key lives in Keybase and travels via KBFS, so a new machine
never needs another machine to be online.

Signing key: `020388768FEBD380` (the primary `[SC]` key — `E9454F08D8C9BE1A`
in the git config is its encryption subkey, which gpg resolves to the same
keyblock).

## One time, from a machine that already holds the secret key

Uploads the private key to `/keybase/private/<you>/.keys/pgp`, encrypted with
your Keybase device keys. It is not protected by the key passphrase alone, so
this is a deliberate trade: convenience on every future machine against
storing the encrypted secret on Keybase's servers.

```bash
keybase pgp push-private 020388768FEBD380
keybase pgp list                            # confirm it is there
```

## On every new machine

```bash
keybase login                 # provisions the device; approve from an
                              # existing device or use a paper key
chmod 700 ~/.gnupg
keybase pgp pull-private 020388768FEBD380
```

Then mark it trusted, or gpg will refuse to use it:

```bash
gpg --edit-key 020388768FEBD380   # trust -> 5 -> y -> save
```

Verify with `./helpers/doctor`, or directly:

```bash
gpg --list-secret-keys 020388768FEBD380
echo test | gpg --clearsign > /dev/null && echo "signing works"
```

Note `push-private` / `pull-private`, **not** `export --secret`. Export reads
the local GnuPG keyring, so it only ever works on a machine that already has
the key — which is the one machine you do not need it on.

SEE: https://github.com/pstadler/keybase-gpg-github
