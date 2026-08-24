# Port of zsh/.zshrc, zsh/.zshrc-aliases and zsh/.zshrc-functions.
#
# Bugs from the old files fixed by construction here:
#   - hardcoded /opt/homebrew zsh-syntax-highlighting path -> syntaxHighlighting
#   - /opt/homebrew/opt/{libpq,mysql-client}/bin on PATH -> dropped, use devShells
#   - the tec agent block appearing twice -> not carried over at all
#   - `mkd` reads markdown with glow; it does not mkdir
#   - `oops` was missing the leading `git`
#   - `cleanlocalbranches` used `|` where it meant `&&`, and left `^main` unquoted
#   - `ghcr-login` was a double-quoted alias, so $GITHUB_TOKEN was interpolated
#     at definition time (i.e. empty) -> it is a function now
#
# Not carried over, deliberately: `lc` (colorls), `goodmorning` (graphite) and
# `devswitch` (`dev tree`, a Shopify /opt/dev command the minidev fork does not
# have). All three are work-machine tooling.
{ lib, pkgs, ... }:

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

      # `|` here was a typo for `&&` — the old alias piped checkout's (empty)
      # stdout into `git branch`, so it ran regardless of whether checkout
      # succeeded. `^main` was unquoted and word-split by zsh.
      cleanlocalbranches =
        ''git checkout main && git branch | grep -v "^main" | xargs git branch -D'';

      # was `reset --soft HEAD~1` — no `git`.
      oops = "git reset --soft HEAD~1";

      set-secrets = "$(cat ~/.secrets)";

      matrix = ''LC_ALL=C tr -c "[:digit:]" " " < /dev/urandom | dd cbs=$COLUMNS conv=unblock | GREP_COLOR="1;32" grep --color "[^ ]"'';
    };

    # Split deliberately. p10k's instant prompt must be the FIRST thing in
    # the rc or it prints a warning and does nothing; home-manager's default
    # initContent slot lands well after `source $ZSH/oh-my-zsh.sh`.
    # mkOrder 500 == before everything, 1000 == the normal slot.
    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      (lib.mkOrder 1000 ''
        # Secrets, if present. Never tracked in this repo.
        [ -f ~/.zshrc-secrets ] && source ~/.zshrc-secrets

        export GPG_TTY=$(tty)

        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-robbyrussell.zsh

        # Markdown CLI reader.
        mkd() { glow -t "$@" }

        schema_status() { opencode run "What's the status of migration: $@" }

        # A function, not an alias: the old double-quoted alias expanded
        # $GITHUB_TOKEN when the alias was defined, not when it was run.
        ghcr-login() {
          echo "$GITHUB_TOKEN" | docker login ghcr.io -u georgef-dev --password-stdin
        }

        source ${./cleanup.zsh}
      '')
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
