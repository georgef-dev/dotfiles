# AI CLIs. Kept out of core.nix because a machine someone else administers
# should not get these by default.
#
# These three move fast — nixpkgs will always trail their own release
# channels. `nix flake update` is the upgrade path; don't let claude-code or
# codex self-update in place, since the store path is read-only and the
# attempt will just fail confusingly.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
    codex
    opencode # `schema_status` in programs/zsh shells out to this
  ];
}
