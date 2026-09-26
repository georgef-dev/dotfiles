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
      # ---------------------------------------------------------------------
      # Optional modules, picked per host. core.nix is always included; a host
      # adds only what it is actually for. A typo here fails at eval naming
      # the missing attribute, so a host's list cannot silently drift.
      # ---------------------------------------------------------------------
      bundles = {
        dev = ./nix/home/extras/dev.nix; # editor, LSPs, ambient runtimes
        ai = ./nix/home/extras/ai.nix;
        infra = ./nix/home/extras/infra.nix;
        containers = ./nix/home/extras/containers.nix;
        media = ./nix/home/extras/media.nix;
        terminal = ./nix/home/extras/terminal.nix; # tmux, herdr, mosh, minidev
      };

      workstation = [ "dev" "ai" "infra" "containers" "media" "terminal" ];

      # homeDirectory is derived from username so the two cannot drift apart;
      # out of sync, home-manager writes into a directory that does not exist.
      hosts = {
        mac = {
          system = "aarch64-darwin";
          username = "georgeferreira";
          platform = ./nix/home/darwin.nix;
          bundles = workstation;
        };
        vm-dev-01 = {
          system = "x86_64-linux";
          username = "georgeferreira";
          platform = ./nix/home/linux.nix;
          bundles = workstation;
        };
        # Homelab container host. AI tooling and a multiplexer, no dev
        # toolchain -- see nix/home/server.nix for what it deliberately omits.
        infra-nuc = {
          system = "x86_64-linux";
          username = "devops";
          platform = ./nix/home/server.nix;
          bundles = [ "ai" "terminal" ];
        };
      };

      homeFor = host:
        if builtins.match ".*-darwin" host.system != null
        then "/Users/${host.username}"
        else "/home/${host.username}";

      # terraform is BUSL-licensed and therefore "unfree" in nixpkgs.
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHome = host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor host.system;
          modules = [
            ./nix/home/core.nix
            host.platform
            {
              home = {
                inherit (host) username;
                homeDirectory = homeFor host;
                stateVersion = "25.05";
              };
            }
          ] ++ map (name: bundles.${name}) host.bundles;
        };

    in {
      homeConfigurations = {
        "gf@mac" = mkHome hosts.mac;
        "gf@vm-dev-01" = mkHome hosts.vm-dev-01;
        "gf@infra-nuc" = mkHome hosts.infra-nuc;
      };

      devShells = nixpkgs.lib.genAttrs
        [ "aarch64-darwin" "x86_64-linux" ]
        (system: import ./nix/devshells { pkgs = pkgsFor system; });
    };
}
