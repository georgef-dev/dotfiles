# Package cleanup decisions

Confirmed choices for the new shared inventory during migration. This is a
record of decisions, not a second installation manifest. Package names and
platform mappings live in `chezmoi/.chezmoidata/packages.yaml`.

## CLI extras

| Tool | Decision |
| --- | --- |
| btop | Keep across personal machines; replaces htop |
| htop | Leave out; use btop |
| tree | Keep |
| wget | Keep |
| mosh | Keep |
| glow | Drop |
| nmap | Drop |
| lolcat | Drop |

Dropped entries are not migrated into the new inventory. Existing Mac/VM
Home Manager declarations and historical Brewfile entries remain until those
hosts migrate; this decision does not uninstall their existing software.

## Identity and encrypted storage

| Tool | Decision |
| --- | --- |
| Keybase | Keep |
| GnuPG | Leave out of the personal tool inventory; retire legacy personal setup during host migration |

Keybase installation on the Dell is pending a reviewed package source: it is not
in this machine's configured package repositories. Its legacy Mac/VM setup stays
in place until those hosts migrate.

GnuPG remains installed on the Dell as an operating-system dependency required
by pacman (and gpgme). Dropping it as a personal tool does not remove that package
or change system package verification. Git already uses SSH commit signing.

Legacy configuration still declares GnuPG, gpg-agent/pinentry, and `GPG_TTY` in
`nix/home/core.nix`, `nix/home/linux.nix`, and
`nix/home/programs/zsh/default.nix`. `helpers/doctor` also mentions an old Keybase
PGP import in a KBFS warning; it does not execute that import. These references
are not proof of active personal use. Revisit them during Mac/VM migration rather
than carrying the legacy PGP setup into the new environment.

## AI tools

| Tool | Decision |
| --- | --- |
| Claude Code | Keep; retain Omarchy's existing mise provider on the Dell |
| Codex | Keep; retain Omarchy's existing mise provider on the Dell |
| rtk | Keep; Dell installation pending a reviewed package source |
| OpenCode | Keep; retain Omarchy's existing mise provider on the Dell |

No duplicate Claude Code, Codex, or OpenCode packages are introduced. OpenCode
remains enabled through Omarchy's mise declaration. Its legacy `schema_status`
helper and custom Neovim integration are separate configuration choices; keeping
the CLI does not deploy those integrations on the Dell.

## Containers

Keep Docker CLI, Compose, Buildx, and lazydocker across personal machines.
Use Colima running Docker on the Mac and native Docker Engine on Omarchy and
Debian. Colima is not needed on the Linux hosts.

The Dell already has Docker, Compose, and Buildx; lazydocker is added through
its native package inventory. This selection does not change Docker services,
contexts, credentials, or existing container data. Mac and Debian installation
sources remain to be verified during their migrations; null apt mappings mark
unresolved package sources rather than dropped tools.

## Media and documents

| Tool | Decision |
| --- | --- |
| ffmpeg | Drop |
| tesseract | Drop |
| pandoc | Drop |
| graphviz | Drop |
| httrack | Drop |

None are selected for the new personal inventory. Existing installations and
legacy Mac/VM declarations remain until those hosts migrate; packages needed by
other applications can remain as dependencies.

## Infrastructure

| Tool | Decision |
| --- | --- |
| terraform | Keep |
| tflint | Keep |
| terraform-docs | Drop |
| terraform-ls | Drop |
| tfsec | Drop |
| cloudflared | Drop |
| istioctl | Drop |

Terraform and tflint use native Arch packages on the Dell. Their Mac and Debian
package sources remain to be verified during host migration; null mappings mark
that pending work. The dropped tools are excluded from the new inventory;
legacy host declarations and existing installations remain until migration.

## Repository workflow

Keep minidev and its native Ruby runtime. The Dell uses the existing personal
checkout path and Bash integration; project environments retain ownership of
project-specific runtime versions.

## Language runtimes

Prefer project-scoped runtimes through Nix development environments. Do not add
Node.js or Go as global fallback runtimes in the new personal inventory.
Project-specific Python and Ruby versions also belong to project environments.

Native Python remains a dependency of the Herdr helpers, and native Ruby remains
a dependency of minidev. These tool dependencies do not select project runtime
versions. Existing OS/application dependencies and legacy host installations are
not removed by this decision.

## Browsers, passwords, and notes

| App | Decision |
| --- | --- |
| 1Password | Keep |
| Google Chrome | Keep |
| Firefox | Keep |
| Chromium | Drop from personal inventory |
| Joplin | Drop |
| Obsidian | Drop from personal inventory |

The kept apps use native packages from this Dell's configured repositories.
Mac cask installation and Debian package sources remain pending host migration,
represented by null mappings. Chrome is already the Dell's default browser;
this selection does not change it. Existing Omarchy applications are not
uninstalled, and the legacy Joplin configuration remains until host migration.

## Communication and music

| App | Decision |
| --- | --- |
| Discord | Keep |
| Spotify | Keep |
| Zoom | Drop |

Discord and Spotify use native packages from the Dell's configured repositories.
Mac cask installation and Debian sources remain pending host migration, marked
with null mappings. Zoom is excluded from the new inventory; existing
installations and legacy host declarations remain until migration.
