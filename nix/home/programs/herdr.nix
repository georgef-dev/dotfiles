# herdr: the terminal multiplexer, plus the navigation plugin its keybindings
# depend on.
#
# config.toml stays in the herdr/ stow package rather than moving here — the
# local plugins under herdr/plugins/ reference absolute ~/dotfiles paths.
#
# Resolves to herdr 0.8.0 from the pinned nixpkgs; `nix flake update` is the
# lever if a newer version is needed.
{ config, lib, pkgs, ... }:

let
  navigation = pkgs.callPackage ../../pkgs/vim-herdr-navigation.nix { };
in
{
  home.packages = [ pkgs.herdr ];

  # config.toml binds ctrl+h/j/k/l to `vim-herdr-navigation.<direction>` as
  # `type = "plugin_action"`. With the plugin absent those actions do not
  # exist and the keys silently do nothing — `herdr config check` still
  # reports ok, because the TOML is valid either way.
  #
  # Linking is imperative because herdr records plugins in
  # ~/.config/herdr/plugins.json, which it writes itself; home-manager cannot
  # own that file. Keyed on the store path, so this re-links on upgrade and
  # is a no-op otherwise.
  home.activation.herdrNavigationPlugin =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      herdr_bin="${pkgs.herdr}/bin/herdr"
      if [ -x "$herdr_bin" ] \
         && ! "$herdr_bin" plugin list 2>/dev/null | grep -qF "${navigation}"; then
        run "$herdr_bin" plugin link "${navigation}" > /dev/null
        verboseEcho "linked vim-herdr-navigation from ${navigation}"
      fi
    '';
}
