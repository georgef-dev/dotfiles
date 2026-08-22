# Phase 1: minimal but usable — the VM chsh's to this shell, so it has to
# stand on its own. Phase 2 ports the rest of zsh/.zshrc-aliases and
# zsh/.zshrc-functions and retires the stow package.
#
# Three bugs from the old zsh/.zshrc are fixed by construction here:
#   - hardcoded /opt/homebrew zsh-syntax-highlighting path -> syntaxHighlighting
#   - /opt/homebrew/opt/{libpq,mysql-client}/bin on PATH -> dropped, use devShells
#   - the tec agent block appearing twice -> not carried over at all
{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "docker-compose" ];
    };

    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];

    shellAliases = {
      tf = "terraform";
      dps = ''docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'';
      inv = ''nvim $(fzf -m --preview="bat --color=always {}")'';
      fzc = ''fzf --height $(( $LINES / 2 )) -m --preview="bat --color=always {}"'';
      newtask = "git fetch --no-tags origin main && git checkout main";
      rebasemain = "git fetch --no-tags origin main && git rebase origin/main";
      gs = "git switch $(git branch | fzf)";
      gitdeletenontrackingbranches =
        "git branch -D $(git branch -vv | grep -v origin | awk '{print $1}')";
    };

    initContent = ''
      # p10k instant prompt must stay at the very top of the rc.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Secrets, if present. Never tracked in this repo.
      [ -f ~/.zshrc-secrets ] && source ~/.zshrc-secrets

      export GPG_TTY=$(tty)

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-robbyrussell.zsh

      mkd() { mkdir -p "$@" && cd "$@"; }
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
