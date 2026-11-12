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

GnuPG and Keybase still need a separate decision because of their possible
identity and encrypted-storage uses.
