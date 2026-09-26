# Using Nix Home Manager

Packages and most config live in a flake, pinned by `flake.lock`, so the mac
and `vm-dev-01` run identical versions.

| | |
| --- | --- |
| Repo | `~/dotfiles` |
| Hosts | `gf@mac`, `gf@vm-dev-01`, `gf@infra-nuc` |
| Apply changes | `hms` |
| Health check | `./helpers/doctor` |

`hms` picks the flake ref from the hostname, so it is the same command everywhere.

## Hosts and bundles

`core.nix` is portable and always applied. Everything optional is a **bundle**,
and each host in `flake.nix` lists the ones it wants:

| Host | User | Bundles |
| --- | --- | --- |
| `mac` | georgeferreira | dev ai infra containers media terminal |
| `vm-dev-01` | georgeferreira | dev ai infra containers media terminal |
| `infra-nuc` | devops | ai terminal |

| Bundle | Contents |
| --- | --- |
| `dev` | neovim, language servers, ambient python3/node/go |
| `ai` | claude-code, codex, opencode, rtk |
| `infra` | terraform toolchain, cloudflared, istioctl |
| `containers` | docker CLI, buildx, compose, lazydocker |
| `media` | ffmpeg, tesseract, pandoc, graphviz, httrack |
| `terminal` | herdr + plugins, mosh, minidev |

A host that omits `dev` gets no editor and no ambient runtimes — that is the point.
`terminal` is deliberately separate from `dev`: cloning a repo and moving between
worktrees is not an editor concern, so a server can take `ai` + `terminal` and be
productive without a toolchain.
`helpers/bootstrap` and `helpers/doctor` read the same table from
`helpers/lib/host.sh`, so stow packages and health checks follow the bundles too.

**Adding a host**: add it to `hosts` in `flake.nix`, to `HOST_TABLE` in
`helpers/lib/host.sh`, and to the `case` in `hms`.

**Changing a host's bundles**: edit both `flake.nix` and `HOST_TABLE`, then:

```bash
hms                 # packages converge on their own -- dropped ones leave
                    # ~/.nix-profile and their generated files are deleted
./helpers/sync      # report what home-manager cannot see
./helpers/sync --apply
```

`sync` covers stow packages (linked by hand, so they survive a dropped
bundle), herdr's imperative plugin registrations, the minidev checkout, and
reminds you that dropped packages sit in the store until garbage collection.

---

## Apply a change

Edit anything under `nix/`, then:

```bash
hms                 # rebuild + activate
exec zsh -l         # only if shell config changed
```

You do not need to commit first — `hms` reads the working tree. But **new
files must be `git add`ed**, or the flake cannot see them and you get a
confusing "file not found".

For prompt-only edits, `p10k reload` is faster than a new shell.

## Add a package

Find the attribute name first — https://search.nixos.org is faster than the
CLI, which evaluates the whole package set on a cold cache:

```bash
nix search nixpkgs ripgrep
```

Then put it in the right file:

| File | For |
| --- | --- |
| `nix/home/core.nix` | portable, safe on any host including a work machine |
| `nix/home/extras/{dev,ai,infra,containers,media,terminal}.nix` | opt-in bundles |
| `nix/home/darwin.nix` | macOS only |
| `nix/home/linux.nix` | the dev VM |
| `nix/home/server.nix` | service hosts |
| `nix/home/linux-base.nix` | every non-NixOS linux host |

```nix
home.packages = with pkgs; [
  ripgrep
];
```

Then `hms`.

**Not in nixpkgs?** Write a derivation in `nix/pkgs/` and reference it with
`callPackage` — see `nix/pkgs/rtk.nix` and how `extras/ai.nix` pulls it in.

**Needs a daemon?** It probably does not belong in Home Manager. See
"What Nix does not manage".

## Update packages

```bash
nix flake update        # rewrites flake.lock
hms
# happy? then:
git add flake.lock && git commit -m "Update flake inputs" && git push
```

**Update on one machine, verify, push, then `git pull && hms` on the other.**
Updating both independently produces two lockfiles and throws away the
guarantee that they match.

Targeted updates, because the two inputs fail differently — nixpkgs changes
package versions, home-manager can rename or remove *options*:

```bash
nix flake update nixpkgs
nix flake update home-manager
```

`nix/pkgs/rtk.nix` pins its own version and hashes, so `nix flake update`
never touches it. Bumping it is manual; the recipe is in that file's header.

## Roll back

```bash
git checkout flake.lock && hms      # before committing
home-manager generations           # after — note the store path
/nix/store/<path>/activate         # activate an earlier one
```

There is no `home-manager rollback`; you run a generation's `activate` script
by path.

## Per-project toolchains

There are no version managers. Each project declares its own toolchain and
`direnv` loads it on `cd`.

```bash
echo 'use flake ~/dotfiles#node' > .envrc && direnv allow
```

Shells in `nix/devshells/default.nix`: `default` (python3/node/go), `node`,
`python`, `ruby`, `rust`.

A project with its own `flake.nix` uses plain `use flake`.

`core.nix` carries python3, node and go ambiently so an ad-hoc script in
`~` still runs. Per-project versions shadow those.

The prompt's `nix_shell` segment names the loaded devShell, falling back to
the direnv project directory. Give new devShells a `name` so it reads well.

## Free disk space

The store grows and never shrinks on its own.

```bash
du -sh /nix/store
home-manager expire-generations "-30 days"
nix-collect-garbage -d               # user profiles
sudo nix-collect-garbage -d          # system profile
```

Garbage collection deletes anything not reachable from a live generation or a
GC root. Run `hms` after, so the current generation is definitely rooted.

## Set up a new machine

```bash
git clone https://github.com/georgef-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./helpers/bootstrap
exec "$HOME/.nix-profile/bin/zsh" -l
./helpers/doctor
```

Add the host to `hosts` in `flake.nix` and to the `case` in `hms` first.

`bootstrap` does nothing without `--host`, on any platform — run it bare for help,
which also prints which host this machine matches. It refuses outright if the
hostname or user does not match the host you asked for.

Then, per machine:

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing
./helpers/allowed-signers <other-host>
```

## Helpers

| | |
| --- | --- |
| `helpers/bootstrap` | bare machine → working env; idempotent |
| `helpers/doctor` | read-only health check; exit code is the failure count |
| `helpers/allowed-signers` | write `~/.config/git/allowed_signers` |
| `helpers/teardown` | undo a bootstrap on the VM; refuses to run on macOS |
| `helpers/herdr-unfold` | one-time: stop herdr writing into the repo |
| `helpers/sync` | reconcile a machine after its bundles change |
| `helpers/lib/host.sh` | host table shared by bootstrap, doctor and sync |

---

## What Nix does not manage

| | Update with |
| --- | --- |
| Homebrew casks (macOS GUI apps) | `brew update && brew upgrade --cask` |
| nvim plugins | `:Lazy update`, then commit `lazy-lock.json` |
| herdr plugins | `herdr plugin ...` |
| tailscale, docker daemon | apt / their own updaters |

**Daemon + CLI pairs are deliberately excluded** — Home Manager cannot own a
system systemd unit, so installing only the Nix CLI half leaves it with
nothing to talk to. `docker` and `tailscale` come from the system. keybase is
the exception: it runs as a *user* service, which Home Manager can manage.

Still on GNU Stow, linked by `bootstrap`: `nvim` (pins its own plugins via
`lazy-lock.json`), `herdr` (plugins reference absolute `~/dotfiles` paths),
`ghostty` and `joplin` (macOS GUI config).

---

## Troubleshooting

**"Existing file is in the way"** — `hms` passes a timestamped `-b` suffix, so
this should not happen. If it does, the named `.bak` file already exists;
delete it.

**Option renamed after a home-manager update** — the error names the old and
new option. Fix the module and `hms`. This is why the two inputs are worth
updating separately.

**A change did not take effect** — `git pull` alone does nothing. Files are
symlinks into `/nix/store` and the path is fixed at activation, so you must
`hms`.

**Config lives outside the repo** — three times during the migration a live
config turned out to be untracked (`~/.gitconfig`, the p10k config, the herdr
precmd hook). If a setting behaves differently between the two hosts, check
whether it is actually in `nix/`.

**`~/.gitconfig` overrides Home Manager.** Home Manager writes
`~/.config/git/config`, and git gives `~/.gitconfig` higher precedence. If
that file exists, HM's git settings are silently inert.

**`stow` refuses: "not owned by stow"** — the existing symlink points through
`~/dotfiles` rather than the resolved path. Remove it and re-run; the content
is in the repo.

**p10k prompt changed unexpectedly** — the config is
`nix/home/programs/zsh/p10k.zsh`, installed to `~/.p10k.zsh`. To change it,
run `p10k configure`, then copy `~/.p10k.zsh` back over the repo file.
