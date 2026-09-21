# herdr: the terminal multiplexer and the three plugins its config depends on.
#
# config.toml stays in the herdr/ stow package rather than moving here, so
# `p10k`-style live edits keep working; only plugin wiring is declarative.
#
# Resolves to herdr 0.8.0 from the pinned nixpkgs; `nix flake update` is the
# lever if a newer version is needed.
{ config, lib, pkgs, ... }:

let
  navigation = pkgs.callPackage ../../pkgs/vim-herdr-navigation.nix { };
  spreader = pkgs.callPackage ../../pkgs/herdr-spreader.nix { };

  dotfiles = "${config.home.homeDirectory}/dotfiles";

  # Linked from the working tree, not the store: this one is ours, it has a
  # test suite, and linking the repo path means edits take effect without a
  # home-manager switch.
  sidebar = "${dotfiles}/herdr/plugins/active-pane-sidebar";
in
{
  home.packages = [ pkgs.herdr ];

  # `herdr plugin install` clones into ~/.config/herdr/plugins/, which is a
  # stow symlink into this repo — it checks third-party source, and its .git,
  # into the working tree. Linking pinned store paths avoids that entirely.
  #
  # Linking stays imperative because herdr owns ~/.config/herdr/plugins.json
  # and writes it itself; home-manager cannot manage that file. Each check is
  # keyed on the path, so this re-links after an upgrade and is otherwise a
  # no-op.
  home.activation.herdrPlugins =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      herdr_bin="${pkgs.herdr}/bin/herdr"
      [ -x "$herdr_bin" ] || return 0

      link_plugin() {
        if ! "$herdr_bin" plugin list 2>/dev/null | grep -qF "$1"; then
          run "$herdr_bin" plugin link "$1" > /dev/null
          verboseEcho "linked herdr plugin $1"
        fi
      }

      # ctrl+h/j/k/l -- config.toml binds these as plugin_action, so without
      # the plugin the keys silently do nothing and `herdr config check`
      # still reports ok.
      link_plugin "${navigation}"

      # ctrl+s v workspace launcher.
      link_plugin "${spreader}"

      # Sidebar rows: focused pane directory, worktree, branch, git state.
      link_plugin "${sidebar}"

      # Spreader reads its layout from its own config dir, so point that at
      # the copy in this repo. config-dir only resolves once linked.
      spreader_config="$("$herdr_bin" plugin config-dir herdr-spreader 2>/dev/null || true)"
      if [ -n "$spreader_config" ]; then
        run mkdir -p "$spreader_config"
        run ln -sfn "${dotfiles}/herdr/spreader/config.yaml" \
          "$spreader_config/config.yaml"
      fi
    '';
}
