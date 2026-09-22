# herdr plugin supplying the ctrl+h/j/k/l actions that
# herdr/.config/herdr/config.toml binds as `vim-herdr-navigation.<direction>`.
#
# Packaged rather than `herdr plugin install`ed because that command clones
# into ~/.config/herdr/plugins/, which is a stow symlink into this repo — it
# checked 212K of third-party source, and its .git, straight into the working
# tree. Pinned here instead, and linked from the store by programs/herdr.nix.
#
# Never goes on PATH: herdr loads it by path, it is not a program.
#
# Upgrading: bump rev, set hash to lib.fakeHash, build once, paste back the
# hash nix reports.
{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "vim-herdr-navigation";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "paulbkim-dev";
    repo = "vim-herdr-navigation";
    rev = "79679dacc791f70fc34de8b29a3cf9706c0f5b2f";
    hash = "sha256-iF0DLRn56eLGqY2iKTb3lX5iyVgl9CtSX5O2E5/pHjM=";
  };

  dontBuild = true;

  # herdr reads herdr-plugin.toml from the plugin root and runs
  # `bash navigate.sh` relative to it, so keep the layout verbatim.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R herdr-plugin.toml navigate.sh editor $out/
    runHook postInstall
  '';

  meta = {
    description = "Seamless ctrl+h/j/k/l navigation across herdr panes and Vim/Neovim splits";
    homepage = "https://github.com/paulbkim-dev/vim-herdr-navigation";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
