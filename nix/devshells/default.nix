# Starting points for per-project `.envrc` files containing `use flake`.
# These are NOT ambient — core.nix carries a small fallback set for that.
#
# `name` is load-bearing, not cosmetic: p10k's nix_shell segment renders it,
# so the prompt says which toolchain is live. Unnamed shells all show the
# same generic string, which is useless when devShells are the only thing
# deciding your python/node/ruby version.
{ pkgs }:

{
  default = pkgs.mkShell {
    name = "default";
    packages = with pkgs; [ python3 nodejs go ];
  };

  node = pkgs.mkShell {
    name = "node";
    packages = with pkgs; [ nodejs pnpm yarn typescript ];
  };

  python = pkgs.mkShell {
    name = "python";
    packages = with pkgs; [ python3 uv ruff ];
  };

  ruby = pkgs.mkShell {
    name = "ruby";
    packages = with pkgs; [ ruby rubyPackages.solargraph ];
  };

  rust = pkgs.mkShell {
    name = "rust";
    packages = with pkgs; [ cargo rustc rust-analyzer clippy ];
  };
}
