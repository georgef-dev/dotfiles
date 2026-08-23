# Debian 13 VM (x86_64-linux), accessed over SSH only.
{ pkgs, ... }:

{
  # The single most important non-NixOS setting. Fixes XDG_DATA_DIRS so
  # completions and desktop files resolve, and points LOCALE_ARCHIVE at the
  # nix glibc — without it, git/perl emit `setlocale` warnings on every call.
  targets.genericLinux.enable = true;

  # Two tools are deliberately absent from this list because they are
  # daemon+CLI pairs that must stay in version lockstep, and home-manager
  # cannot manage a system systemd unit on Debian:
  #   docker    -> sudo apt install docker.io
  #   tailscale -> installed by helpers/bootstrap via tailscale.com/install.sh
  # Installing only the nix CLI half gives you a binary with nothing to
  # talk to. cloudflared IS in extras/infra.nix, but note that running a
  # persistent tunnel needs `cloudflared service install` on top.
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

  # Unlike docker and tailscale above, keybase runs as a *user* service, so
  # home-manager can own its systemd unit on Debian without sudo.
  services.keybase.enable = true;

  programs.git.settings.gpg.program = "${pkgs.gnupg}/bin/gpg";
}
