# What makes a terminal session productive, independent of whether the host
# does any development: a multiplexer, a connection that survives roaming,
# and the tooling to find and move between repositories.
#
# Deliberately usable alongside `ai` without `dev` — cloning a repo and
# navigating to it is not an editor concern.
{ lib, pkgs, ... }:

{
  imports = [
    ../programs/tmux
    ../programs/herdr.nix
    ../programs/minidev.nix # `dev clone`, `dev cd`, worktree navigation
  ];

  home.packages = with pkgs; [
    mosh # ssh that survives a changed network or a closed laptop
  ]
  # tmux shells out to this for clipboard integration on macOS; it is
  # meaningless without tmux, so it belongs with tmux rather than in
  # darwin.nix.
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ reattach-to-user-namespace ];
}
