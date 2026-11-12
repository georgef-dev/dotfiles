# Migration status

## Omarchy Dell: CLI and core Herdr migration

The first implementation is on `plan/chezmoi-migration`, following the
[goal](chezmoi-migration-goal.md) and [plan](chezmoi-migration-plan.md).
See [Using chezmoi](using-chezmoi.md) for daily commands and recovery.

### Starting state and ownership

- Host `gf-omarchy`, Omarchy 4.5.0, Bash login shell.
- No Nix, Home Manager, chezmoi, or existing `~/dotfiles` link.
- Neovim and Herdr already installed, with ordinary Omarchy configuration
  directories. Herdr's live directory also contains runtime state and sockets.
- Git used `George Ferreira <gf@georgeferreira.com>`; the legacy Nix configuration
  uses a different email. The Dell's existing identity is preserved in local
  chezmoi data rather than copied into shared source.
- SSH authentication key already existed. No private keys were generated or moved.

### Implemented and verified

- `.chezmoiroot` isolates deployable source under `chezmoi/`, allowing legacy
  Home Manager/Stow files and the project flake to coexist during migration.
- One tool-oriented inventory defines the initial native CLI baseline: chezmoi,
  Git, Neovim, ripgrep, jq, GitHub CLI, direnv, fzf, bat, ShellCheck, and Nix for
  projects. Native packages are installed. No existing packages were removed.
- Chezmoi owns `.bashrc`, a personal Bash fragment, Git preferences/global ignores,
  the user Nix flakes setting, and a mise override for native GitHub CLI.
- Bash still loads Omarchy's environment and maintained defaults before personal
  settings. Editor variables and the direnv hook work in a fresh session.
- Git retains Omarchy's aliases, diff settings, rerere, sorting, and push behavior;
  shared preferences select `main` and Neovim. Local SSH signing is enabled and
  a signed commit verifies using the machine's public key. Local allowed-signers
  data stays outside Git. GitHub key registration status was not changed.
- Native Nix and its socket-activated daemon work without Home Manager. The
  existing `default` devShell ran Node, Python, and Go from the pinned flake.
- Dry-run inspected; live apply and reapply succeeded; `chezmoi diff` is empty
  and `chezmoi verify` succeeds.
- `tests/check-chezmoi.py` passes all four profile renders, non-migrated-host guards,
  temporary-HOME apply/reapply, and shell syntax checks. An independent agent
  reviewed initial configuration and package integration.

The original checkout under `~/src/github.com/georgef-dev/dotfiles` was left
untouched. The active chezmoi checkout is `~/Work/dotfiles` on the PR branch.
Backups of the initial target files are outside Git; see the usage document.

### Dell audit: 2026-11-12

The selected Dell baseline is working. All 34 inventory packages are installed;
`chezmoi verify` succeeds and file-only diff is empty. The four-profile migration
check passes, as do all eight workspace-launcher and eight sidebar tests.

An interactive Bash startup selects Neovim and loads minidev; real `dev cd`
navigation succeeds. Herdr configuration validates, all three plugins are enabled,
and all six plugin actions are registered. Docker service/socket and the Nix
socket are active; both sockets are enabled for boot. Nix's existing default
project shell runs Node, Python, and Go. The current commit's SSH signature verifies.
RTK reports its global Codex hook, instructions, and reference configured.

A scan of the current contents of branch-changed files found no common private-key
or credential-token patterns. This is a limited pattern check, not proof that
all possible secrets are absent. Credentials and application runtime state remain
outside chezmoi ownership.

### Deliberate deferrals and remaining decisions

- Keep trying Omarchy's Neovim setup; personal editor migration and editor-side
  Herdr navigation handoff remain deferred.
- Bash remains in use. No switch to Zsh is needed to finish this baseline.
- Keybase account login and other application sign-ins are user-local steps;
  this audit did not inspect credentials or exercise authenticated services.
- RTK's Codex setup was checked; automatic command rewriting and integration
  with each other agent were not exercised by this audit.
- Selected GUI packages are installed, and Etcher's desktop entry was checked
  during setup. Interactive GUI behavior and the nonworking Docker hotkey were
  not retested.
  Use `sudo lazydocker` from a terminal with Omarchy's default access model.
- Remaining legacy Homebrew formulae and Mac App Store selections need review
  on the Mac. They are not implicitly retained or dropped. Linux service choices
  beyond the selected Docker/Nix baseline have not been newly migrated.

### Personal Mac handoff

Continue on `plan/chezmoi-migration`, draft PR #13. Read the goal, plan, usage
instructions, and [package decisions](package-cleanup.md) before implementation.
Inspect the Mac's actual Home Manager, Stow, shell, and package ownership first.
The personal-Mac profile is still guarded: do not apply the Omarchy profile there.

Implement Homebrew formula/cask selection from the shared inventory, including
Mac-only decisions currently recorded in the decision log. Null mappings mean
unresolved sources, not unwanted tools. Preserve Colima as the Mac Docker backend,
project-scoped runtimes, local identity/signing, and Nix project dependencies.
Transfer configuration ownership in small verified steps before retiring Home
Manager/Stow on that host. Mac, VM, and work-machine validation is still pending.

## Other machines

| Machine | Status |
| --- | --- |
| Personal MacBook | Not migrated; existing HM/Stow setup retained. Next portability target after the Dell workflow is established. |
| Development VM | Not migrated; existing HM/Stow setup retained. apt mappings are provisional. |
| Shopify work MacBook | Not migrated; selective future adoption only. |
| infra-nuc | Existing setup retained; migration scope still unresolved. |

Non-Omarchy profiles currently fail before package installation and ignore the
new managed files. They have rendered/guard checks, not real platform validation.
No Home Manager modules or Stow packages were removed, and no other host was
activated or changed.

## Herdr migration details

The core Herdr config is rendered from the existing source with portable popup
paths and Ctrl+S bindings. Ctrl+S then lowercase `v` opens the user-selected personal layout:
a workspace-name prompt, Neovim on the left, and two shells on the right in the
invoking directory. This launcher uses native Herdr APIs rather than the
Shopify-specific Spreader wrapper, which remains for legacy hosts. Chezmoi deploys the pinned navigation archive outside
Git and registers it plus the personal sidebar and PR-board plugins. A Bash
prompt hook replaces the legacy Zsh sidebar refresh for this host. Herdr, Python,
and lazygit are included in the native inventory.

The focused integration check covers config schema, portable paths, plugin source
registration, archive deployment with a local fixture, apply/reapply, unchanged
session data, rejection of folded directory symlinks, and prompt-hook idempotence.
Eight focused launcher tests cover the returned workspace/pane IDs, cwd and
layout, default naming, cancellation, failure cleanup, readiness timeout, and
argument quoting. Interactive popup behavior and crossing Neovim boundaries remain
separate from static configuration validation. No existing workspace or pane is closed.

## Package cleanup

The first [cleanup decisions](package-cleanup.md) select btop instead of htop,
and retain tree, wget, and mosh. Glow, nmap, and lolcat are excluded from the new
inventory. The legacy sources remain available until their hosts migrate.

Keybase is retained through the reviewed AUR `keybase-bin` package. GnuPG is
excluded as a personal tool; the OS package remains because pacman requires it.
Legacy GnuPG package/agent/pinentry and GPG_TTY declarations, plus an old PGP-import
warning in the health check, remain to be retired during legacy-host migration.
These configuration references do not establish active personal use.

AI-tool cleanup retains Claude Code, Codex, and OpenCode through Omarchy's existing
mise providers. rtk is kept through the reviewed AUR `rtk-bin` package. Keeping
OpenCode does not deploy the legacy shell/editor integrations.
