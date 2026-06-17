# ============================================================================
# 1. P10K INSTANT PROMPT — must stay at the very top.
# Anything that prompts the user (passwords, [y/n]) must go ABOVE this block.
# ============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#                      __
#                     / _|
#                __ _| |_
#               / _` |  _|
#              | (_| | |
#               \__, |_|
#                __/ |
#               |___/

# ============================================================================
# 2. SECRETS — sourced early so later config can use the values.
# ============================================================================
[ -f ~/.zshrc-secrets ]      && source ~/.zshrc-secrets
[ -f ~/.zshrc-secrets-shop ] && source ~/.zshrc-secrets-shop

# ============================================================================
# 3. ENVIRONMENT VARIABLES (non-PATH)
# ============================================================================
export GPG_TTY=$(tty)
export VISUAL=nvim
export NVM_DIR="$HOME/.nvm"
export ZSH="$HOME/.oh-my-zsh"

# ============================================================================
# 4. OH-MY-ZSH — config, then load.
# ============================================================================
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode reminder      # just remind me; don't auto-update
plugins=(git brew github docker docker-compose aws)
source $ZSH/oh-my-zsh.sh

# Personal aliases + functions
source ~/.zshrc-aliases
source ~/.zshrc-functions

# p10k theme override (must come after oh-my-zsh.sh)
[[ -f ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh ]] && \
  source ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh

# ============================================================================
# 5. TOOL INITIALIZERS — most of these modify PATH or set up shims.
# Order matters: brew first (sets /opt/homebrew/bin), then anything that
# depends on it. tec last because it may layer on top of everything else.
# ============================================================================

# Homebrew
[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# NVM
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

# mise (runtime version manager) — guard since the binary may not be installed
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

# chruby — lazy-loaded; the function sources chruby.sh on first call.
[[ -f /opt/dev/sh/chruby/chruby.sh ]] && {
  type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
}

# Shopify dev (or local minidev fallback)
if [ -f /opt/dev/dev.sh ]; then
  source /opt/dev/dev.sh
elif [ -f ~/src/github.com/georgef-dev/minidev/dev.sh ]; then
  source ~/src/github.com/georgef-dev/minidev/dev.sh
fi

# tec agent (auto-injected tool layer)
[[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && \
  eval "$(~/.local/state/tec/profiles/base/current/global/init zsh)"

# ============================================================================
# 6. PATH — single consolidated block. Last word wins, dedupe at the end.
#
# Convention:
#   - Prepend (`<dir>:$PATH`) for things that should beat system defaults.
#   - Append (`$PATH:<dir>`) for fallbacks (local bins, language toolchains).
# ============================================================================

# AI tool user bins (highest precedence — my installs beat any system equivalent)
export PATH="$HOME/.pi/agent/bin:$PATH"          # `todo` + future pi CLIs

# Project workflow bins
export PATH="$HOME/src/github.com/shopify-playground/georgef/.claude/skills/orchestra/runtime/bin:$PATH"
export PATH="$HOME/home-world/tools:$PATH"

# Homebrew lib clients (the keg-only ones brew shellenv doesn't expose)
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Lower-precedence user bins (appended)
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/src/bin"
export PATH="$PATH:/usr/local/texlive/2022basic/bin/universal-darwin"

# Dedupe — must run after every PATH mutation above.
export PATH=$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')

# ============================================================================
# 7. COMPLETIONS + INTERACTIVE EXTRAS — last, so completions see the final PATH
# and zsh-syntax-highlighting wraps every prior widget.
# ============================================================================
autoload -U compinit && compinit -i
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
source <(fzf --zsh)

# MUST be the very last `source` per zsh-syntax-highlighting docs.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Added by tec agent
[[ -x /Users/georgeferreira/.local/state/tec/profiles/base/current/global/init ]] && eval "$(/Users/georgeferreira/.local/state/tec/profiles/base/current/global/init zsh)"
