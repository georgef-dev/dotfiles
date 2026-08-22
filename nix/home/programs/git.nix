# Replaces the previously-untracked ~/.gitconfig.
# NOTE: commit.gpgsign is on. On a fresh host the signing key must be
# imported first (see README) or every commit will fail.
{ ... }:

{
  programs.git = {
    enable = true;

    signing = {
      key = "E9454F08D8C9BE1A";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "George Ferreira";
        email = "fs.georgee@gmail.com";
      };
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };

    ignores = [ "**/.claude/settings.local.json" ];
  };
}
