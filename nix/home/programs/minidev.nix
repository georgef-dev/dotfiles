# minidev — personal fork of Shopify's `dev`, sourced as a shell function.
#
# Owns both halves of the dependency so it can be dropped from a host in one
# line: the ruby interpreter that bin/dev shebangs into, and the shell hook.
# The repo itself is cloned by helpers/bootstrap, not by nix — it is a working
# checkout you edit, not a pinned build input.
{ config, lib, pkgs, ... }:

let
  minidevDir = "${config.home.homeDirectory}/src/github.com/georgef-dev/minidev";
in
{
  # bin/dev is `#!/usr/bin/env -S ruby --disable-gems`. This is a tool
  # dependency, not a project runtime, so it belongs in the profile rather
  # than a devShell.
  home.packages = [ pkgs.ruby ];

  # mkOrder 1200 keeps this after the main initContent block (1000), matching
  # the position dev.sh held in the old hand-written .zshrc.
  programs.zsh.initContent = lib.mkOrder 1200 ''
    [ -f "${minidevDir}/dev.sh" ] && source "${minidevDir}/dev.sh"
  '';
}
