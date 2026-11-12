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
