#!/usr/bin/env bash
# Wrapper script for RuboCop formatter.
#
# Runs rubocop under the project's own toolchain rather than whatever Ruby
# happens to be on PATH. Gems in a nix-flake project's vendor/bundle have
# native extensions linked to an absolute nix-store libruby, so running them
# under e.g. Homebrew's same-version Ruby fails with "linked to incompatible".

set -euo pipefail

# Shopify repos: shadowenv provides the toolchain.
if [ -f ".shadowenv.d/.gitignore" ] || [ -f "dev.yml" ]; then
    if command -v shadowenv >/dev/null 2>&1; then
        eval "$(shadowenv hook bash)"
    fi
fi

# nix + direnv repos: re-enter the project env so `bundle` is the flake's.
if [ -f ".envrc" ] && command -v direnv >/dev/null 2>&1; then
    NIX_BIN=/nix/var/nix/profiles/default/bin
    [ -d "$NIX_BIN" ] && export PATH="$NIX_BIN:$PATH"
    export DIRENV_LOG_FORMAT=""
    exec direnv exec "$PWD" bundle exec rubocop "$@"
fi

if [ -f "Gemfile" ]; then
    exec bundle exec rubocop "$@"
else
    exec rubocop "$@"
fi
