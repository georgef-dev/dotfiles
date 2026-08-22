# Container CLIs. The daemon/VM that backs them is platform-specific and
# lives in darwin.nix (colima) or linux.nix (native docker).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-client
    docker-buildx
    docker-compose
    lazydocker
  ];
}
