# Chezmoi migration plan: Omarchy first

Read the [goal and boundaries](chezmoi-migration-goal.md) first. Implementation
has started on the Dell XPS running Omarchy; consult the
[migration status](chezmoi-migration-status.md) before continuing on this branch.
There is no need to merge the PR before continuing the work.

The Dell is new and only starting to be used, making it the first target with
less established configuration to disrupt. Build the shared setup here, validate
portability on the personal Mac next, and migrate the development VM afterward.
Keep the Mac's and VM's current environments working in the meantime.

## 1. Inspect the Dell and establish the current state

Read repository and ancestor `AGENTS.md` guidance, the README,
`docs/using-nix-home-manager.md`, and relevant component documentation. Existing
instructions describe the current Nix-based architecture; this migration
intentionally changes global package and configuration ownership. Preserve
unrelated conventions and update guidance as the implementation changes.

Compare declarations with the actual machine: installed packages, active shell,
PATH, configuration locations, symlink targets, user services, and local changes.
Distinguish Omarchy-provided defaults, local customizations, and missing tools.
Use the existing dotfiles as a reference for the desired workflow rather than
assuming every declared package is needed here. Inspect without
collecting or committing secrets.

Useful starting points in this repository:

- `flake.nix`, `nix/home/core.nix`, platform modules, and `nix/home/extras/`
  describe hosts and package selections.
- `nix/home/programs/` contains shell, Git, direnv, Herdr, and minidev behavior
  that must survive outside Home Manager where still wanted.
- `brew/.Brewfile` records the existing macOS GUI/application selection.
- `helpers/` handles bootstrap, host selection, health checks, and Stow links.
- `nvim/`, `herdr/`, `ghostty/`, and `joplin/` contain Stow-managed configuration.
- `nix/pkgs/` contains custom packages and pinned plugin sources that need an
  explicit destination or documented exception.
- `nix/devshells/` and project `.envrc` usage are retained capabilities.

Produce a concise ownership/inventory assessment, including live configuration
missing from Git. Record how to recover the working setup before changing it.

## 2. Propose the minimal structure

Choose a chezmoi organization that supports one authoritative package inventory,
platform mappings, and machine/role selection. Distinguish global tools, desktop
applications, project dependencies, and system services. Account for packages
requiring vendor repositories or nonstandard sources, and identify unavailable
tools rather than silently omitting them.

Decide how the existing repository location and chezmoi source directory relate.
Several helpers and Herdr plugins assume `~/dotfiles`; preserve or deliberately
replace those assumptions. Determine how to transfer ownership from Home Manager
and Stow without two tools managing the same target.

Document the choices briefly as part of implementation. File formats, exact
commands, and template structure are intentionally not prescribed by this plan.

## 3. Establish a small useful slice on the Dell

Start with a manageable configuration and a few everyday CLI tools. Preserve
existing Omarchy settings and integrations when introducing shared preferences,
preview the resulting changes, and verify the native binaries are the ones the shell actually resolves.

Establish the normal edit, preview, apply, commit, and synchronize workflow. Check
that a repeated apply is uneventful before expanding the migration. Installation
should not unexpectedly perform a broad upgrade or remove unrelated packages.

## 4. Expand to the daily workflow

Migrate the selected global packages and configurations incrementally. Preserve
Git identity and per-machine SSH signing, wanted shell/prompt behavior, editor
mappings and plugin locks, directory navigation, Herdr integrations, and wanted applications.
Retain the distinction between portable preferences and platform integration.
Inspect Omarchy shell initialization before choosing whether to keep its shell
or adopt the existing Zsh workflow; preserve required environment integration.

Pay particular attention to:

- Home Manager store symlinks and configuration precedence when transferring files.
- Login-shell and PATH dependencies on the Nix profile; keep a working recovery
  shell during the transition.
- Herdr plugin registration and pinned sources currently supplied by Nix.
  Runtime state, sockets, logs, and third-party checkouts must not enter Git.
- System services and their clients, including Docker and Tailscale; retain
  coherent native ownership and any needed user-service behavior.
- AI tools and other rapidly changing applications whose native update paths
  differ from pinned Nix packages.

Keep Nix and direnv usable for projects. Verify existing devShell entry points,
including references to this repository, before retiring related shell setup.

## 5. Validate on the personal Mac, then prepare the VM

Once the Dell workflow is useful, adopt the same source on the personal Mac.
Inventory its live Home Manager and Stow ownership before transferring files and
packages to chezmoi and Homebrew. Preserve the working Mac environment until each
replacement is verified. Use this second platform to validate the shared model
and refine platform differences without duplicating the inventory.

Prepare the VM selection next, keeping desktop applications optional. Replace
assumptions that all Linux systems use apt. Work-Mac adoption remains selective
and must respect Shopify's setup.

Use rendering and previews where useful, but record actual application and smoke
testing as pending until performed on each target. Leave infra-nuc operational
while its scope remains unresolved.

## 6. Retire obsolete ownership and document the new workflow

On each migrated machine, retire previous configuration and global-package
ownership only after replacements work. The Dell may have no Home Manager
environment to retire; inspect rather than assume. Retire the personal Mac's
Home Manager dependency when its own migration is verified. Do not uninstall Nix
or delete project devShells. Avoid removing declarations still needed by hosts that
have not migrated, and distinguish staged coexistence from the final design.

Update the README, agent guidance, and bootstrap/health-check documentation so
they accurately describe what manages each machine. Retire obsolete helpers or
adapt them where useful; avoid leaving two competing documented workflows.

## Evidence and handoff

Record the following in the implementation PR as work progresses:

- What changed on the Dell and each subsequent target, which files and packages
  changed ownership, and how recovery works.
- Successful preview/apply/reapply, a fresh terminal session, key tool resolution,
  Git configuration/signing checks, and representative editor/Herdr behavior.
- A working project Nix environment on the Dell, and continued project Nix
  functionality after migration on the Mac and VM.
- Any missing native equivalents, additional package sources, deferred decisions,
  and remaining Nix global dependencies.
- Separate status for Omarchy validation first, Mac validation next, and VM
  validation afterward, plus a concise next-machine adoption procedure.

Keep commits reviewable and this branch usable as a handoff. The goal is a working,
understandable migration, with implementation details chosen from evidence on the
actual machines.
