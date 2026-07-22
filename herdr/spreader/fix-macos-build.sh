#!/usr/bin/env bash
set -euo pipefail

plugin_id="herdr-spreader"
config_dir=$(herdr plugin config-dir "$plugin_id")
plugin_root=$(
  herdr plugin list --json | python3 -c '
import json, sys
plugins = json.load(sys.stdin)["result"]["plugins"]
print(next(plugin["plugin_root"] for plugin in plugins if plugin["plugin_id"] == "herdr-spreader"))
'
)

expression=$(mktemp)
trap 'rm -f "$expression"' EXIT
cat >"$expression" <<EOF
let
  pkgs = import <nixpkgs> {};
  src = pkgs.lib.cleanSourceWith {
    src = $plugin_root;
    filter = path: type:
      let name = builtins.baseNameOf path;
      in name != ".git" && name != "target";
  };
in pkgs.rustPlatform.buildRustPackage {
  pname = "herdr-spreader";
  version = "0.1.0";
  inherit src;
  cargoLock.lockFile = $plugin_root/Cargo.lock;
  doCheck = true;
}
EOF

output=$(nix-build --no-out-link "$expression")
root_link="$config_dir/nix-build"
nix-store --add-root "$root_link" --indirect --realise "$output" >/dev/null
ln -sfn "$root_link/bin/herdr-spreader" "$plugin_root/target/release/herdr-spreader"

"$plugin_root/target/release/herdr-spreader" \
  apply --file "$HOME/dotfiles/herdr/spreader/config.yaml" --dry-run
