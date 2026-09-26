# Editor and language tooling. Split out of core.nix so a host can take the
# portable CLI, or the `ai` bundle, without pulling an editor, three language
# servers and three language runtimes.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    # Language servers. nvim needs these ambient rather than per-project,
    # because it loads them before any devShell is entered.
    lua-language-server
    typescript-language-server
    nil

    # Ambient fallback runtimes. Deliberate: without these `python3 foo.py`
    # in $HOME fails, now that pyenv/nvm/mise are gone. Per-project versions
    # come from devShells via direnv and shadow these on PATH.
    python3
    nodejs
    go
  ];
}
