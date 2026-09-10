# Portable baseline. Everything here must be safe on ANY host, including a
# work machine someone else administers: no cloud credentials, no opinions
# about infrastructure. Host-specific or domain-specific tools go in extras/.
{ pkgs, ... }:

{
  imports = [
    ./programs/zsh
    ./programs/git.nix
    ./programs/tmux
    ./programs/direnv.nix
    ./programs/minidev.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Core CLI
    gh
    neovim
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
    mosh
    nmap
    # Terminal multiplexer. Config is the herdr/ stow package, not a nix
    # module -- its plugins reference absolute ~/dotfiles paths.
    # Resolves to 0.8.0 from the pinned nixpkgs; 0.9.0 is current upstream,
    # so `nix flake update` is the lever if a newer version is needed.
    herdr
    keybase # identity + encrypted storage, not just the gpg key
    lolcat
    stow # still needed while nvim/ghostty/joplin remain stow packages

    # Language servers — nvim needs these ambient, not per-project
    lua-language-server
    typescript-language-server
    nil

    # Ambient fallback runtimes (see note below)
    python3
    nodejs
    go
  ];

  # Ambient fallback runtimes. Deliberate: without these, `python3 foo.py`
  # in $HOME fails now that pyenv/nvm/mise are gone. Per-project versions
  # still come from devShells via direnv and shadow these on PATH.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
