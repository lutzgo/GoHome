{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [
        inputs.nixos-unified.flakeModules.default
      ];

      perSystem = { pkgs, ... }:
        let
        # Define the list of users here
          userNames = [
            "lgo"
            "sgo"
          ]; 
        in
        {
          legacyPackages.homeConfigurations = builtins.listToAttrs (
            map
            (userName: {
                name = userName;
                value =
                  self.nixos-unified.lib.mkHomeConfiguration
                  pkgs
                  ({ pkgs, ... }: {
                    imports = [ self.homeModules."${userName}" ]; # import user specific module
                    home.username = userName;
                    home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${userName}";
                    home.stateVersion = "25.05";
                  });
              }
            )
            userNames
          );
        };

      flake = {
        # All home-manager configurations are listed here.
        homeModules = {
          # The default configuration, can be used as fallback for any user,
          # or if you only have one user.
          default = import ./modules/shared;
          lgo = import ./modules/lgo;
          otheruser = import ./modules/sgo;
        };
      };
    };
}
