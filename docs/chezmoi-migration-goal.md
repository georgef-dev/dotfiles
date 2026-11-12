# Goal: a familiar environment with native package management

Status: agreed direction; implementation design and migration remain to be done.
Start with the [migration plan](chezmoi-migration-plan.md) on this branch.

## Why change

Nix and Home Manager are still a trial for global packages and configuration.
Their complexity is not justified by the level of consistency needed at home.
The aim is familiar tools and workflows across personally owned machines, with
each operating system installing and upgrading its own applications. Identical
global package versions are not a requirement.

Nix remains useful for project dependencies across operating systems. Preserve
that capability independently of retiring Home Manager and global Nix packages.

## Machines

| Machine | Intended treatment |
| --- | --- |
| Personal MacBook | Second target to validate portability; Homebrew for native packages and applications |
| Development VM | Shared development workflow; apt for native packages |
| Dell XPS running Omarchy (`gf-omarchy`) | First migration target; Omarchy/Arch package tooling and desktop integration |
| Shopify-managed work MacBook | Optional, selective reuse within employer constraints; drift is expected |

The repository also defines `infra-nuc`. Its continued role is an open question;
preserve its existing setup until its migration scope is established.

## Desired result

- Chezmoi manages shared dotfiles and intentional machine differences in this
  repository.
- One authoritative inventory describes desired tools and applications, with
  platform package mappings and machine/role selections where needed. Avoid
  maintaining independent hand-edited inventories that silently drift.
- Installation delegates to Homebrew, apt, and Omarchy/Arch tooling. Ordinary
  upgrades stay with those native tools.
- Machines get the software appropriate to their role. A VM need not install
  desktop applications, and a work machine need not receive the personal setup.
- Shell behavior, Git preferences, editor configuration, and repository navigation
  are familiar across personal machines. Preserve intentional host differences.
- Nix project environments continue to work without Home Manager activation.
- Normal operations are understandable: preview changes, apply them, edit a
  managed file, synchronize machines, and diagnose missing tools.

## Boundaries

Native package managers determine available global versions. Exact requirements
such as Ruby 4.0.1 belong with project dependencies unless there is a demonstrated
need for an exact global version and an explicitly documented exception.

Chezmoi coordinates configuration and package-installation scripts; it does not
provide a universal package-name or repository abstraction automatically. Make
unavailable packages, third-party sources, and platform exceptions visible.

Omarchy continues to own its desktop defaults and integration. Shared dotfiles
should coexist with those defaults through supported user customization points.

Removing an entry from the inventory should not silently uninstall software.
Package removal and bulk cleanup are separate, deliberate migration decisions.
Secrets, credentials, private keys, and application runtime state stay out of Git.
Preserve per-machine SSH signing and authentication identities.

## Decisions left to implementation

Choose the source layout, inventory schema, host selection, script organization,
template usage, and transition away from Stow after inspecting the Dell and its existing Omarchy setup.
Earlier conversational snippets were illustrations, not an agreed implementation.
Use the simplest arrangement that meets the outcomes above; avoid building a
general-purpose package-management framework.

## Success criteria

The Dell has the desired development workflow using native global packages and
chezmoi-managed configuration, while retaining Omarchy desktop integration and
supporting Nix project environments. Repeated application makes no unnecessary
changes. The personal Mac then validates portability, followed by the VM. A clear
record identifies what was exercised on each machine and what remains untested.
The existing Mac and VM setups stay operational until each is migrated; neither
the work Mac nor infra-nuc must migrate at the same time.
