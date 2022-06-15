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
export PATH=$PATH:"$HOME/platform_engineering/bin"
export PATH=$PATH:"$HOME/go/bin"
export PATH=$PATH:"$HOME/gferreira/scripts"


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

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel9k/powerlevel9k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

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

ZSH_TMUX_AUTOSTART="true"

plugins=(git brew tmux tmuxinator github docker docker-compose aws)

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

# Personal aliases
alias set-secrets='$(cat ~/.secrets)'
alias tf='terraform'
alias gitaddmod="git add \$(git status | grep modified | awk '{print \$2}')"
alias brew-update='brew update && brew outdated && brew upgrade && brew cu --all --cleanup --yes && brew cleanup && brew doctor;'

eval "$(rbenv init - zsh)"

if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

# Workarounding Electric

if [[ $(hostname) -eq "gf-mbp" ]]; then
  export USER=georgeferreira
fi

~/dotfiles/scripts/login


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