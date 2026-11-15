{
  description = "TLA+ specs checked with TLC";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-linux" ];
    in {
      devShells = nixpkgs.lib.genAttrs systems (system: {
        # tlaplus wraps tla2tools.jar with its own JDK: tlc, pcal, tlasany, tlatex.
        default = nixpkgs.legacyPackages.${system}.mkShell {
          name = "tla";
          packages = [ nixpkgs.legacyPackages.${system}.tlaplus ];
        };
      });
    };
}
