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
cd ~/dotfiles && ./helpers/bootstrap          # prints help + which host you are
./helpers/bootstrap --host <host> --dry-run   # read the plan
./helpers/bootstrap --host <host>             # apply it
```

`--host` is **required** and is checked against this machine's hostname and
user before anything is touched — applying the wrong host would write into
another user's home directory. Run bare for the host list.

On a bare Linux box that is everything: apt prerequisites, Nix, Tailscale,
Home Manager, the login shell, an SSH key, and the stow packages this host
wants. On macOS, run it from a **second terminal** so you keep a working
shell if the new one fails.

Per machine, once:

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication   # required: git
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing          # commits verify
./helpers/allowed-signers <other-host>                       # verify locally
```

# Nix / Home Manager

Day-to-day tasks: [docs/using-nix-home-manager.md](docs/using-nix-home-manager.md).

Packages and most dotfiles are declared in a flake and pinned by
`flake.lock`, so both machines get identical versions.

```bash
hms                     # rebuild + activate this host
nix flake check         # validate a change before switching
nix flake update        # upgrade everything, then hms
home-manager generations # roll back
./helpers/doctor        # health check
./helpers/sync          # reconcile after changing a host's bundles
```

Three hosts, each taking `core.nix` plus the bundles it is for:

| Host | Bundles |
| --- | --- |
| `mac` | dev ai infra containers media terminal |
| `vm-dev-01` | dev ai infra containers media terminal |
| `infra-nuc` | ai terminal |

Layout:

- `nix/home/core.nix` — portable baseline, on every host
- `nix/home/extras/` — the bundles (`dev`, `ai`, `infra`, `containers`,
  `media`, `terminal`)
- `nix/home/{darwin,linux,server,linux-base}.nix` — platform modules
- `nix/home/programs/` — zsh, git, direnv, herdr, minidev
- `nix/pkgs/` — packages not in nixpkgs, pinned to a commit
- `nix/devshells/` — per-project toolchains
- `reference/` — retired configs, kept for reference, imported by nothing

# Per-project runtimes

There are no version managers. Each project declares its own toolchain:

```bash
echo 'use flake ~/dotfiles#node' > .envrc && direnv allow
```

Available shells: `default` (python3/node/go), `node`, `python`, `ruby`,
`rust`. A small fallback set is on `PATH` ambiently for ad-hoc scripts.

# Homebrew

macOS only, and only for GUI casks and `mas`. Every CLI tool comes from Nix.

# Stow

A few configs Home Manager does not own are still linked with
[GNU Stow](https://www.gnu.org/software/stow/):

| Package | Why not Home Manager |
| --- | --- |
| `nvim` | pins its own plugins via `lazy-lock.json` |
| `herdr` | its plugins reference absolute `~/dotfiles` paths |
| `ghostty`, `joplin` | macOS GUI apps |

`helpers/bootstrap` links the ones this host's bundles want, and
`helpers/sync` relinks or unlinks them when those bundles change. You should
not need to run `stow` by hand.

# nvim

Open nvim and run `:Lazy`. Plugin versions are pinned in `lazy-lock.json`;
commit it after `:Lazy update`.

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
