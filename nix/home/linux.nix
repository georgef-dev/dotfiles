# Debian 13 VM (x86_64-linux), accessed over SSH only.
{ pkgs, ... }:

{
  # The single most important non-NixOS setting. Fixes XDG_DATA_DIRS so
  # completions and desktop files resolve, and points LOCALE_ARCHIVE at the
  # nix glibc — without it, git/perl emit `setlocale` warnings on every call.
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    # NB: the docker CLI comes from extras/containers.nix. The daemon is a
    # system service on Debian (`sudo apt install docker.io`), not a
    # home-manager package — adding pkgs.docker here collides on bin/docker.
    xclip # nvim clipboard over X forwarding
    wl-clipboard

    # nvim-treesitter compiles its parsers with a C compiler, and mason
    # unpacks the LSP servers it downloads. A bare Debian has neither, so
    # :Lazy would install and then fail on every parser build.
    gcc
    gnumake
    unzip
  ];

  programs.git.settings.gpg.program = "${pkgs.gnupg}/bin/gpg";
}
