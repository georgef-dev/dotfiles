# AI CLIs. Kept out of core.nix because a machine someone else administers
# should not get these by default.
{ pkgs, ... }:

{
  # `schema_status` in programs/zsh shells out to this.
  home.packages = [ pkgs.opencode ];
}
