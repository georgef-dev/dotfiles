# shellcheck shell=bash
# Host table, shared by helpers/bootstrap and helpers/doctor.
#
# Must stay in step with `hosts` in flake.nix. Each row is:
#   <host>|<expected hostname>|<expected user>|<bundles>
#
# The mac's hostname is not stable -- macOS rewrites it on some networks --
# so it matches on uname instead, written here as "*".
HOST_TABLE='mac|*|georgeferreira|dev ai infra containers media terminal
vm-dev-01|vm-dev-01|georgeferreira|dev ai infra containers media terminal
infra-nuc|infra-vm-coreapp-nuc|devops|ai terminal'

host_row()     { printf '%s\n' "$HOST_TABLE" | awk -F'|' -v h="$1" '$1==h'; }
host_names()   { printf '%s\n' "$HOST_TABLE" | cut -d'|' -f1; }
host_field()   { host_row "$1" | cut -d'|' -f"$2"; }
host_hostname(){ host_field "$1" 2; }
host_user()    { host_field "$1" 3; }
host_bundles() { host_field "$1" 4; }

# Stow packages a host should have linked, derived from its bundles. Shared by
# bootstrap (which links them) and sync (which also unlinks what is no longer
# wanted), so the two cannot disagree.
host_stow_packages() {
  local h="$1" pkgs=""
  host_has_bundle "$h" dev      && pkgs="$pkgs nvim"
  host_has_bundle "$h" terminal && pkgs="$pkgs herdr"
  [ "$h" = "mac" ] && pkgs="$pkgs ghostty joplin"
  printf '%s' "${pkgs# }"
}

# Every stow package this repo can link, wanted or not.
# shellcheck disable=SC2034  # consumed by helpers/sync
ALL_STOW_PACKAGES="nvim herdr ghostty joplin"

# herdr must not be folded: folded, ~/.config/herdr is a single symlink into
# this repo and everything herdr writes -- logs, session.json, plugins.json,
# its sockets -- lands in the working tree.
stow_no_folding() { [ "$1" = "herdr" ]; }

host_has_bundle() {
  case " $(host_bundles "$1") " in *" $2 "*) return 0 ;; *) return 1 ;; esac
}

this_hostname() { hostname -s 2>/dev/null || hostname; }

# Which row, if any, describes the machine we are running on. Prints the host
# name, or nothing. A "*" hostname matches only on Darwin.
detect_host() {
  local me_host me_user name want_host want_user
  me_host="$(this_hostname)"
  me_user="${USER:-$(id -un)}"
  for name in $(host_names); do
    want_host="$(host_hostname "$name")"
    want_user="$(host_user "$name")"
    [ "$want_user" = "$me_user" ] || continue
    if [ "$want_host" = "*" ]; then
      [ "$(uname -s)" = "Darwin" ] && { printf '%s\n' "$name"; return 0; }
    elif [ "$want_host" = "$me_host" ]; then
      printf '%s\n' "$name"; return 0
    fi
  done
  return 1
}
