# herdr-spreader: the Ctrl+s v workspace launcher.
#
# herdr expects the binary at <plugin_root>/target/release/herdr-spreader,
# which the manifest's [[build]] block would normally produce with
# `cargo build --release`. Building it locally is what herdr/spreader/
# fix-macos-build.sh existed to work around: macOS AMFI SIGKILLs unsigned
# locally-built Rust binaries, so that script built it in the nix store and
# GC-rooted it by hand. This does the same thing declaratively, which retires
# the script.
#
# Linking does not trigger [[build]], so the block is left as upstream wrote
# it; the prebuilt binary simply satisfies the action first.
#
# Upgrading: bump rev, set hash to lib.fakeHash, build once, paste back.
{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "herdr-spreader";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "yuk1ty";
    repo = "herdr-spreader";
    rev = "206ae55aff2de0828623ea4e8fc9c6ab28519935";
    hash = "sha256-nPuL1MUsMpgJYi0rPPBUdffp/SrI7T1fDkQBBVq/QZY=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  # Lay $out out as a herdr plugin root: the manifest at the top, and the
  # binary where the manifest's action expects to find it.
  postInstall = ''
    mkdir -p $out/target/release
    ln -s $out/bin/herdr-spreader $out/target/release/herdr-spreader
    cp $src/herdr-plugin.toml $out/
  '';

  meta = {
    description = "Apply tmuxinator-style project layouts from YAML in herdr";
    homepage = "https://github.com/yuk1ty/herdr-spreader";
    license = lib.licenses.mit;
    mainProgram = "herdr-spreader";
    platforms = lib.platforms.unix;
  };
}
