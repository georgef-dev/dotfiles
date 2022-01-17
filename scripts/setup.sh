#!/bin/bash
set -euo pipefail
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf '
                      __ 
                     / _|
                __ _| |_ 
               / _` |  _|
              | (_| | |  
               \__, |_|  
                __/ |    
               |___/    

Setting up...

' | lolcat

if [ ! -d "$HOME/.oh-my-zsh/" ]; then
    echo "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || echo "Failed to install Oh My Zsh" >&2
    echo "Installing PowerLevel9k Them for Oh My Zsh"
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k || echo "Failed to install Powerlevel9k" >&2
fi

printf 'All set!' | lolcat
echo ; echo