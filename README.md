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

Day-to-day tasks: [docs/using-nix-home-manager.md](docs/using-nix-home-manager.md).

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

# Commit signing

Commits are signed with **SSH**, not GPG. Each machine signs with an ed25519
key it generated itself, so no private key ever travels between machines and
losing one means revoking a single key on GitHub rather than rotating an
identity everywhere.

`helpers/bootstrap` generates `~/.ssh/id_ed25519` if it is missing. Register
it once per machine:

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing
gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication
```

Until the signing key is registered, commits are still signed locally but
GitHub shows them as *Unverified*.

Check it works:

```bash
./helpers/doctor                        # covers format, key, and signing
git commit --allow-empty -m test && git log --show-signature -1
```

## Verifying your own signatures locally

`gpg.ssh.allowedSignersFile` points at `~/.config/git/allowed_signers`, which
needs one line per machine — without it `git log --show-signature` cannot
verify even your own commits.

```bash
./helpers/allowed-signers                  # add this machine
./helpers/allowed-signers vm-dev-01        # also pull keys from those hosts
./helpers/allowed-signers --list
```

Idempotent; re-running updates a key in place rather than duplicating it. The
principal it writes is `user.email`, which is often *not* the comment baked
into the key — git matches on the former.

This only affects local verification — GitHub verifies independently from the
keys registered on your account.

## Revoking a machine

Delete that machine's key from GitHub (Settings → SSH and GPG keys) and drop
its line from `allowed_signers`. Nothing else needs to change.

## The GPG key — REVOKED

`020388768FEBD380` is **compromised and revoked**. Its unencrypted private key
(`secret-key.asc`, no passphrase) was tracked in this public repository from
commit `b970fe1` in 2022 until it was removed. Anyone who cloned the repo in
that window holds a fully usable copy.

Do not use this key. Do not re-import it. Commits it signed should be treated
as unverifiable regardless of what GitHub displays — once the revocation
certificate propagates, GitHub marks them unverified anyway.

Commit signing is now per-machine SSH keys (see above), which is the reason
this key has no remaining job. Nothing in `nix/` references it.

SEE: https://docs.github.com/en/authentication/managing-commit-signature-verification
