#!/usr/bin/env bash
# Wrapper script for RuboCop formatter in Shopify repos

set -euo pipefail

# Check if we're in a Shopify repo with shadowenv
if [ -f ".shadowenv.d/.gitignore" ] || [ -f "dev.yml" ]; then
    if command -v shadowenv >/dev/null 2>&1; then
        eval "$(shadowenv hook bash)"
    fi
fi

# Check if we're in a bundled project
if [ -f "Gemfile" ]; then
    exec bundle exec rubocop "$@"
else
    exec rubocop "$@"
fi
