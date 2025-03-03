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

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# export PATH=$PATH:"$HOME/.gem/ruby/3.3.4/bin"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.gem/ruby/3.4.0-preview2/bin:$PATH"
export PATH=$PATH:"$HOME/.local/bin"
export PATH=$PATH:"$HOME/go/bin"
export PATH=$PATH:"$HOME/gferreira/scripts"
export PATH=$PATH:"/usr/local/texlive/2022basic/bin/universal-darwin"


# Path to your oh-my-zsh installation.

export ZSH="$HOME/.oh-my-zsh"
# Export my secrets
. ~/.secrets

# Modify shell for GPG
export GPG_TTY=$(tty)

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

#source "${HOME}"/.nvm/nvm.sh
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# source "$ZSH/custom/themes//powerlevel10k/config/p10k-robbyrussell.zsh"
# source "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"

ZSH_THEME="powerlevel10k/powerlevel10k"

# source "$(brew --prefix)/opt/gitstatus/gitstatus.prompt.zsh"

PROMPT='%~%# '               # left prompt: directory followed by %/# (normal/root)
RPROMPT='$GITSTATUS_PROMPT'  # right prompt: git status

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# ZSH_TMUX_AUTOSTART="true"

plugins=(git brew github docker docker-compose aws) 

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Work aliases
alias start-local-ftf='rm -rf tmp/pids && dip up -d postgres-dump && dip up rails sidekiq webpacker'
alias start-local-radix="dip up rails sidekiq webpacker postgrest"
alias matrix='LC_ALL=C tr -c "[:digit:]" " " < /dev/urandom | dd cbs=$COLUMNS conv=unblock | GREP_COLOR="1;32" grep --color "[^ ]"'

# Personal aliases
alias set-secrets='$(cat ~/.secrets)'
alias tf='terraform'
alias gitaddmod="git add \$(git status | grep modified | awk '{print \$2}')"
alias gitadddeleted="git add \$(git status | grep deleted | awk '{print \$2}')"
alias gitdeletenontrackingbranches="git branch -D \$(git branch -vv | grep -v origin | awk '{print \$1}')"
alias brew-update='brew update && brew outdated && brew upgrade && brew cu --all --cleanup --yes && brew cleanup && brew doctor'
alias idrive='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs"'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias ghcr-login="echo $GITHUB_TOKEN | docker login ghcr.io -u georgef-dev --password-stdin"
alias lc="colorls"
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'
alias fzc='fzf -m --preview="bat --color=always {}"'

if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

#~/dotfiles/scripts/login


#--------------------------------------------------------------------------
## Personal settings
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Prompt for screenshotting articles/guides
#--------------------------------------------------------------------------

# zsh_custom_prompt(){
#     local prompt_message="AWS SSO TF Guide$ "
#     local color='%F{yellow}'
#     [[ $signal -gt 75 ]] && color='%F{green}'
#     [[ $signal -lt 50 ]] && color='%F{red}'
#     echo -n "%{$color%}\uf230  $prompt_messagel%{%f%}" # \uf230 is 
# }
# POWERLEVEL_9K_CUSTOM_PROMPT_MESSAGE="zsh_custom_prompt"
# POWERLEVEL9K_DISABLE_RPROMPT=true
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_prompt_message)

# Created by `pipx` on 2022-06-21 14:10:33
export PATH="$PATH:/Users/georgeferreira/.local/bin"

# Github CLI autocomplete
autoload -U compinit
compinit -i

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# export PATH=~/platform-engineering/ftf-tools:/Users/georgeferreira/.pyenv/shims:/Users/georgeferreira/.pyenv/bin:/Users/georgeferreira/.rbenv/shims:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/georgeferreira/.local/bin:/Users/georgeferreira/platform_engineering/bin:/Users/georgeferreira/go/bin:/Users/georgeferreira/gferreira/scripts:/Users/georgeferreira/.local/bin:/Users/georgeferreira/platform_engineering/bin:/Users/georgeferreira/go/bin:/Users/georgeferreira/gferreira/scripts:/Users/georgeferreira/.local/bin:/opt/homebrew/opt/fzf/bin

# heroku autocomplete setup

alias photo-compare='/Users/georgeferreira/.cargo/bin/cargo run --release --bin czkawka_gui'

# Localstack

export LOCALSTACK_ENDPOINT=http://localhost:4566

alias awslocal="aws --endpoint-url ${LOCALSTACK_ENDPOINT}"

localstack-restapi-url() {
  # e.g.: `curl $(localstack-api-url my-function) --data '{"foo":"bar"}'`
  local function=$1
  local stage=${2:-stage} # pulumi defaults to 'stage'
  local restapi_id=$(awslocal apigateway get-rest-apis | jq '.items' | grep -B1 "\"name\": \"${function}\"" | head -1 | grep -Eo '[a-z0-9]+' | tail -1)
  [ -z "${restapi_id}" ] && printf "No '${function}' Lambda found in '${stage}'" >&2 && return 1
  echo ${LOCALSTACK_ENDPOINT}/restapis/${restapi_id}/${stage}/_user_request_/${function}
}
# source /opt/homebrew/opt/gitstatus/gitstatus.prompt.zsh
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh.
[[ ! -f ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh ]] || source ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-robbyrussell.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }

