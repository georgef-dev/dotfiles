# Personal Mac (aarch64-darwin). Homebrew still owns the GUI casks and `mas`;
# this file covers only the CLI side that is macOS-specific.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pinentry_mac
    reattach-to-user-namespace # tmux clipboard
    colima # docker daemon backend
    lima
    mas
  ];

  programs.git.settings.gpg.program = "${pkgs.gnupg}/bin/gpg";

  # Homebrew must land AFTER nix on PATH so nix wins collisions. The guard
  # keeps brew out of the way inside a nix shell.
  programs.zsh.initContent = ''
    if [[ -z "$IN_NIX_SHELL" && -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # minidev — personal machine only, and a no-op without shadowenv
    if [ -f ~/src/github.com/georgef-dev/minidev/dev.sh ]; then
      source ~/src/github.com/georgef-dev/minidev/dev.sh
    fi
  '';
}
