{
  description = "NixOS + Home-Manager with Node (nvm), pnpm, yarn, Go, Python 3.13, JDK 11";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Optional: flake-compat for `nix build -f .` users
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { inherit system; };
      hostname = "nixos";
      username = "dat";
    in
    {
      nixosConfigurations.${hostname} = lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/common.nix
          ./hosts/${hostname}/configuration.nix

          # Home-Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Back up existing dotfiles instead of failing activation
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
          }
        ];
      };

      # Nice: a dev shell with the same toolchain
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          zsh
          # Languages & runtimes (mirrors what's in Home-Manager)
          go
          python313
          jdk11
          nodejs_22
          pnpm
          yarn
        ];
      };
    };
}
