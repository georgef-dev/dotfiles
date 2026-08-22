# Debian 13 VM (x86_64-linux), accessed over SSH only.
{ pkgs, ... }:

{
  # The single most important non-NixOS setting. Fixes XDG_DATA_DIRS so
  # completions and desktop files resolve, and points LOCALE_ARCHIVE at the
  # nix glibc — without it, git/perl emit `setlocale` warnings on every call.
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    docker # native daemon, no colima needed
    xclip # nvim clipboard over X forwarding
    wl-clipboard
  ];

  programs.git.settings.gpg.program = "${pkgs.gnupg}/bin/gpg";
}
