# rtk — token-minimizing CLI proxy. Not in nixpkgs; homebrew-core has it, but
# Phase 5 wants brew reduced to casks + mas, so it gets a derivation here.
#
# Upgrading: bump version, set srcHash and cargoHash to lib.fakeHash, build
# twice, and paste back the hashes nix reports.
{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "rtk";
  version = "0.45.0";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "v${version}";
    hash = "sha256-weAyHM0nWLrM8JRbbXIfjUsHtAep3DOFyTO+M3BZ/iU=";
  };

  cargoHash = "sha256-tgW6il/xLxt/xwhUBJ4MNVnk0JSZ7iFjJaEobj5+H4o=";

  # The test suite shells out to git, docker and friends; it is checking the
  # proxy's real behaviour against tools that are not in the sandbox.
  doCheck = false;

  meta = {
    description = "CLI proxy that minimizes LLM token consumption";
    homepage = "https://www.rtk-ai.app/";
    license = lib.licenses.asl20;
    mainProgram = "rtk";
    platforms = lib.platforms.unix;
  };
}
