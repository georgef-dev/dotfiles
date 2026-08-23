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

      # Send every github HTTPS URL over SSH instead, so git authenticates
      # with this machine's ed25519 key and no token is stored on disk.
      #
      # This is what makes `dev clone` work: minidev hardcodes
      # https://github.com/<repo> in clone.rb with no ssh path, and without a
      # rewrite git falls through to a username/password prompt that GitHub
      # has rejected since 2021. The rewrite also covers checkouts that
      # already have an HTTPS origin, including minidev's own.
      #
      # Requires this host's key registered for auth, not just signing:
      #   gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication
      url."git@github.com:".insteadOf = "https://github.com/";

      # Lets `git log --show-signature` verify SSH-signed commits locally.
      # Append one line per machine:  <email> ssh-ed25519 AAAA...
      gpg.ssh.allowedSignersFile =
        "${config.home.homeDirectory}/.config/git/allowed_signers";
    };

    ignores = [ "**/.claude/settings.local.json" ];
  };
}
