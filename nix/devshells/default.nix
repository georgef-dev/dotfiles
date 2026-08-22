# Starting points for per-project `.envrc` files containing `use flake`.
# These are NOT ambient — core.nix carries a small fallback set for that.
{ pkgs }:

{
  default = pkgs.mkShell {
    packages = with pkgs; [ python3 nodejs go ];
  };

  node = pkgs.mkShell {
    packages = with pkgs; [ nodejs pnpm yarn typescript ];
  };

  python = pkgs.mkShell {
    packages = with pkgs; [ python3 uv ruff ];
  };

  ruby = pkgs.mkShell {
    packages = with pkgs; [ ruby rubyPackages.solargraph ];
  };

  rust = pkgs.mkShell {
    packages = with pkgs; [ cargo rustc rust-analyzer clippy ];
  };
}
