# Personal Mac (aarch64-darwin). Homebrew still owns the GUI casks and `mas`;
# this file covers only the CLI side that is macOS-specific.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pinentry_mac
    reattach-to-user-namespace # tmux clipboard
    colima # docker daemon backend
    lima

    # Ships docker-credential-osxkeychain. Without a credential helper
    # `docker login` writes the secret base64-encoded into
    # ~/.docker/config.json, in the clear. It used to come from the Docker
    # Desktop cask, so removing that cask left nothing providing it.
    # Set "credsStore": "osxkeychain" in ~/.docker/config.json to use it.
    docker-credential-helpers

    mas
  ];

  programs.git.settings.gpg.program = "${pkgs.gnupg}/bin/gpg";

  # macOS-only: both hardcode paths that do not exist on the VM.
  programs.zsh.shellAliases = {
    brew-update =
      "brew update && brew outdated && brew upgrade && brew cu --all --cleanup --yes && brew cleanup && brew doctor";
    idrive = ''cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs"'';
  };

  # Homebrew must land AFTER nix on PATH so nix wins collisions. The guard
  # keeps brew out of the way inside a nix shell.
  #
  # `brew shellenv` does NOT append to PATH. It runs
  # `path_helper -s` with PATH_HELPER_ROOT=/opt/homebrew, which REBUILDS PATH
  # from scratch with /opt/homebrew/{bin,sbin} at the front. Left alone, every
  # tool migrated to nix would still resolve to the brew copy — the exact
  # inverse of the coexistence rule. So put nix back in front afterwards.
  # typeset -U keeps the array deduped when a subshell re-runs this.
  programs.zsh.initContent = ''
    if [[ -z "$IN_NIX_SHELL" && -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      typeset -U path
      path=("$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin $path)
    fi
  '';
}
