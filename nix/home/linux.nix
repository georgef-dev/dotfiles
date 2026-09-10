# Debian 13 VM (x86_64-linux), accessed over SSH only.
{ pkgs, ... }:

{
  # The single most important non-NixOS setting. Fixes XDG_DATA_DIRS so
  # completions and desktop files resolve, and points LOCALE_ARCHIVE at the
  # nix glibc — without it, git/perl emit `setlocale` warnings on every call.
  targets.genericLinux.enable = true;

  # genericLinux.enable turns this on by default, which makes every activation
  # warn that the GPU is not set up and adds a non-nixos-gpu package to the
  # profile. The check is advisory only -- it reads /run/opengl-driver and
  # prints -- and this is a headless Proxmox VM reached over SSH with no GPU
  # and no graphical apps. Flip it back if that ever changes.
  targets.genericLinux.gpu.enable = false;

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

  # KBFS, for keybase's encrypted storage. Needs FUSE, which bootstrap
  # installs via apt (fuse3).
  services.kbfs.enable = true;

  # Commits are signed with SSH now, so gpg no longer gates committing. It is
  # still kept working for keybase and ad-hoc use: without a pinentry, gpg
  # fails on anything needing a passphrase. Headless box, so it must be a
  # terminal pinentry — the graphical ones have no display to draw on.
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    enableZshIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };

  programs.git.settings.gpg.program = "${pkgs.gnupg}/bin/gpg";
}
