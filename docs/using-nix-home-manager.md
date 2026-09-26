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

**Defining a new bundle**: write `nix/home/extras/<name>.nix` as an ordinary
module, then register it:

```nix
# flake.nix
bundles = {
  # ...
  <name> = ./nix/home/extras/<name>.nix;
};
```

Add it to whichever hosts want it, and to their row in `HOST_TABLE`. A bundle
may `imports` modules from `nix/home/programs/` — that is how `terminal`
pulls in herdr and minidev. If a bundle needs a stow package or an extra
bootstrap step, teach `host_stow_packages` in `helpers/lib/host.sh` about it
so `bootstrap` and `sync` both follow.

Name bundles after what they are for, not after a tool. `terminal` replaced
separate `herdr` and `minidev` bundles for that reason.

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

## Start over on a machine

Linux only, and only for a throwaway box — `teardown` refuses to run on
macOS because it removes the nix store.

```bash
./helpers/teardown            # dry run: lists what goes
./helpers/teardown --yes
```

It resets the login shell *before* removing the store: the other order leaves
your account pointing at a shell that no longer exists, which locks you out of
a machine you reach only over SSH. Determinate's `/nix/nix-installer uninstall`
does the heavy lifting — the reason that installer was chosen.

It does **not** restore a pristine machine: apt prerequisites stay, so the
next bootstrap skips step 1 and leaves it untested. For a real end-to-end
test, roll back to a VM snapshot instead.

On macOS, undo an activation with `home-manager generations` rather than
teardown; Homebrew is untouched, so restoring `~/.zshrc.bak` puts you back.

## Helpers

| | |
| --- | --- |
| `helpers/bootstrap` | bare machine → working env; idempotent |
| `helpers/doctor` | read-only health check; exit code is the failure count |
| `helpers/allowed-signers` | write `~/.config/git/allowed_signers` |
| `helpers/teardown` | remove nix from a throwaway Linux box; refuses on macOS |
| `helpers/herdr-unfold` | one-time: stop herdr writing into the repo |
| `helpers/sync` | reconcile a machine after its bundles change |
| `helpers/lib/host.sh` | host table shared by bootstrap, doctor and sync |

---

## Git and GitHub

`programs/git.nix` rewrites every GitHub HTTPS URL to SSH:

```nix
url."git@github.com:".insteadOf = "https://github.com/";
```

So `git clone https://github.com/...` rides this machine's ed25519 key, and no
token is stored anywhere. It is also what makes `dev clone` work — minidev
hardcodes an HTTPS URL in `clone.rb` with no SSH path, so without the rewrite
it drops to a username/password prompt that GitHub has rejected since 2021.

The cost: `--type authentication` is **mandatory**, not optional. Every fetch
and push goes over SSH, so an unregistered key breaks git entirely rather than
just showing commits as unverified.

`gh` still keeps its own token for `gh pr` and friends — on Linux that sits in
plaintext at `~/.config/gh/hosts.yml`. It no longer participates in git auth.

**Commit signing** is SSH-based and per-machine; see the README.

**Docker registry logins** use the macOS keychain via
`docker-credential-helpers` in `darwin.nix` plus `"credsStore": "osxkeychain"`
in `~/.docker/config.json`. Without a helper, `docker login` writes the secret
base64-encoded, in the clear, into that file.

`~/.docker/config.json` is deliberately **not** managed by Home Manager: docker
writes `auths` to it, and a read-only store symlink would break `docker login`
the way it breaks `gh auth setup-git`.

## Tools with their own state

**herdr sessions.** `herdr` bare attaches to the persistent session, tmux-style.

| | Processes | Scrollback | Layout |
| --- | --- | --- | --- |
| detach (`Ctrl+s d`), then `herdr` | keep running | intact | intact |
| `herdr server stop`, then `herdr` | killed | lost | restored |

A full stop restores workspace names, tabs, layout and each pane's `cwd` from
`session.json`, and resumes agents (`resume_agents_on_restore = true`). It does
not restore what a pane was *running*, and scrollback is gone by design —
`pane_history = false`, because pane output can contain tokens. Do not run
`herdr session delete`; that is the one command that discards the state.

Plugins are declarative: `hms` links them. Never `herdr plugin install` — it
clones into `~/.config/herdr/plugins/`, and if that host is still folded, into
this repo.

**Docker.** The CLI comes from the `containers` bundle; the daemon does not.

```bash
colima start                                   # macOS
sudo apt install docker.io                     # Linux, then usermod -aG docker
```

**Tailscale** is installed by `bootstrap` from tailscale.com, not nix: it is a
daemon and CLI that must stay in lockstep, and Home Manager cannot own a
system systemd unit.

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

**A tool is missing on one host** — check its bundles: `./helpers/bootstrap`
prints them. `infra-nuc` has no `dev` bundle, so it has no neovim and no
ambient python3/node/go, on purpose.

**`bootstrap` refuses with a hostname or user mismatch** — that guard exists
because the config hardcodes a username and home directory, so the wrong host
writes into a home that may not exist. Fix the `--host`, or add the machine to
`HOST_TABLE` and `flake.nix`.

**"This non-NixOS system is not yet set up to use the GPU"** — advisory only,
from `targets.genericLinux`. `linux-base.nix` disables it; if you see it, that
host is not importing `linux-base.nix`.

**p10k prompt changed unexpectedly** — the config is
`nix/home/programs/zsh/p10k.zsh`, installed to `~/.p10k.zsh`. To change it,
run `p10k configure`, then copy `~/.p10k.zsh` back over the repo file.
