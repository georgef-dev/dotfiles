# Settings every non-NixOS Linux host needs, whatever it is for.
#
# Extracted rather than duplicated across linux.nix and server.nix:
# genericLinux.enable is the single most load-bearing setting on a non-NixOS
# distro, and two copies invites fixing one and forgetting the other.
{ ... }:

{
  # Fixes XDG_DATA_DIRS so completions and desktop files resolve, and points
  # LOCALE_ARCHIVE at the nix glibc — without it, git/perl emit `setlocale`
  # warnings on every call.
  targets.genericLinux.enable = true;

  # genericLinux.enable turns this on by default, which makes every activation
  # warn that the GPU is not set up and adds a non-nixos-gpu package to the
  # profile. The check is advisory only -- it reads /run/opengl-driver and
  # prints. These are headless boxes reached over SSH with no GPU and no
  # graphical apps. Flip it back if that ever changes.
  targets.genericLinux.gpu.enable = false;
}
