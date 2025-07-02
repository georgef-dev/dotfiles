# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
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
#
#

# Path to your oh-my-zsh installation.

export ZSH="$HOME/.oh-my-zsh"
# Export my secrets
. ~/.secrets

# Modify shell for GPG
export GPG_TTY=$(tty)

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh" 
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm" 


ZSH_THEME="powerlevel10k/powerlevel10k"

PROMPT='%~%# '               # left prompt: directory followed by %/# (normal/root)
RPROMPT='$GITSTATUS_PROMPT'  # right prompt: git status

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# ZSH_TMUX_AUTOSTART="true"

plugins=(git brew github docker docker-compose aws) 

source $ZSH/oh-my-zsh.sh

# Import aliases from .zshrc-aliases

source ~/.zshrc-aliases

if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi
export PATH="$PATH:/Users/georgeferreira/.local/bin"

# Github CLI autocomplete
autoload -U compinit
compinit -i

source <(fzf --zsh)
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

[[ ! -f ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh ]] || source ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }

export PATH=$PATH:"$HOME/.local/bin"
export PATH=$PATH:"$HOME/go/bin"
export PATH=$PATH:"$HOME/gferreira/scripts"
export PATH=$PATH:"/usr/local/texlive/2022basic/bin/universal-darwin"

# Removes PATH duplicates
export PATH=$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
