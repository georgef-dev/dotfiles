{
  description = "georgef dotfiles — one CLI environment across macOS and Debian";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      hosts = {
        mac = {
          system = "aarch64-darwin";
          username = "georgeferreira";
          homeDirectory = "/Users/georgeferreira";
          platformModule = ./nix/home/darwin.nix;
        };
        vm-dev-01 = {
          system = "x86_64-linux";
          username = "georgeferreira";
          homeDirectory = "/home/georgef";
          platformModule = ./nix/home/linux.nix;
        };
      };

      # terraform is BUSL-licensed and therefore "unfree" in nixpkgs.
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHome = name: host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor host.system;
          modules = [
            ./nix/home/core.nix
            ./nix/home/extras/infra.nix
            ./nix/home/extras/containers.nix
            ./nix/home/extras/media.nix
            host.platformModule
            {
              home = {
                inherit (host) username homeDirectory;
                stateVersion = "25.05";
              };
            }
          ];
        };

    in {
      homeConfigurations = {
        "gf@mac" = mkHome "mac" hosts.mac;
        "gf@vm-dev-01" = mkHome "vm-dev-01" hosts.vm-dev-01;
      };

      devShells = nixpkgs.lib.genAttrs
        [ "aarch64-darwin" "x86_64-linux" ]
        (system: import ./nix/devshells { pkgs = pkgsFor system; });
    };
}
