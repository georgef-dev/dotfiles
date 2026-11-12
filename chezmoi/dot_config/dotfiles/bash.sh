# shellcheck shell=bash
# Personal Bash additions, loaded after Omarchy's defaults.
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim

# Native direnv can load project environments, including Nix flakes once installed.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
