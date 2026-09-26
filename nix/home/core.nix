# Portable baseline. Everything here must be safe on ANY host, including a
# work machine someone else administers or a server that does no development:
# no cloud credentials, no opinions about infrastructure, no dev toolchain.
#
# Anything optional is a bundle picked per host in flake.nix. Editor and
# language tooling live in extras/dev.nix — a container host has no use for
# three language servers.
{ pkgs, ... }:

{
  imports = [
    ./programs/zsh
    ./programs/git.nix
    ./programs/direnv.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gh
    ripgrep
    jq
    tree
    htop
    wget
    gnupg
    bat
    glow
    lazygit
    shellcheck
    nmap
    keybase # identity + encrypted storage, not just the gpg key
    lolcat
    stow # still needed while nvim/ghostty/joplin remain stow packages
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
