# Replaces mise/pyenv/nvm. Per-project toolchains come from a flake devShell
# loaded on `cd` via the chpwd hook. nix-direnv adds caching so re-entering a
# directory does not re-evaluate the flake.
{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
