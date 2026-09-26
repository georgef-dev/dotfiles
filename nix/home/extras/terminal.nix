# What makes a terminal session productive, independent of whether the host
# does any development: a multiplexer, a connection that survives roaming,
# and the tooling to find and move between repositories.
#
# Deliberately usable alongside `ai` without `dev` — cloning a repo and
# navigating to it is not an editor concern.
{ pkgs, ... }:

{
  # tmux was retired here in favour of herdr; the module is kept unimported
  # under reference/tmux/ along with why.
  imports = [
    ../programs/herdr.nix
    ../programs/minidev.nix # `dev clone`, `dev cd`, worktree navigation
  ];

  home.packages = with pkgs; [
    mosh # ssh that survives a changed network or a closed laptop
  ];
}
