# Linux hosts that run services rather than development: infra-nuc today.
#
# Intentionally almost empty. Everything the dev VM carries in linux.nix is
# there for a workflow this host does not have:
#
#   keybase / kbfs        needs FUSE; this box holds no credentials
#   gpg-agent / pinentry  commit signing is SSH-based, so gpg gates nothing
#   xclip / wl-clipboard  for nvim's clipboard, and nvim is in the dev bundle
#   gcc / gnumake / unzip  for nvim-treesitter's parser builds, same reason
#
# The docker CLI is deliberately absent too: this host runs system docker for
# its containers, and a second client ahead of it on PATH is the collision
# already hit on the mac.
#
# Add here only on evidence that something is missing, not in anticipation.
{ ... }:

{
  imports = [ ./linux-base.nix ];
}
