# Replaces the previously-untracked ~/.gitconfig.
#
# Commits are signed with SSH, not GPG: each machine signs with the ed25519
# key it generated itself, so no private key ever leaves the host it was made
# on and losing a machine means revoking one key on GitHub rather than
# rotating an identity everywhere. The GPG key stays in Keybase purely as an
# identity proof — it no longer signs anything.
{ config, ... }:

let
  signingKey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
in
{
  programs.git = {
    enable = true;

    signing = {
      format = "ssh";
      key = signingKey;
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

      # Lets `git log --show-signature` verify SSH-signed commits locally.
      # Append one line per machine:  <email> ssh-ed25519 AAAA...
      gpg.ssh.allowedSignersFile =
        "${config.home.homeDirectory}/.config/git/allowed_signers";
    };

    ignores = [ "**/.claude/settings.local.json" ];
  };
}
