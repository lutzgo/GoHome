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
          userNames = [ "lgo" "otheruser" ]; # Define the list of users here
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
                    home.stateVersion = "22.11";
                    # Define default programs for all user here or you can leave it empty.
                    # For Example:
                    # programs.git.enable = true;
                  });
              }
            )
            userNames
          );
        };

      flake = {
        # All home-manager configurations are kept here.
        homeModules = {
            # The default configuration, can be used as fallback for any user,
            # or if you only have one user.
            default = { pkgs, ... }: {
              imports = [ ];
              programs = {
                # These are default programs for all users
                # git.enable = true; 
              };
            };
            lgo = { pkgs, ... }: {
              imports = [ ];
              programs = {
                git.enable = true;
                starship.enable = true;
                bash.enable = true;
              };
            };
            otheruser = { pkgs, ... }: {
              imports = [ ];
              programs = {
                git.enable = false;  # different config for otheruser
                #starship.enable = true;
                zsh.enable = true;
                #bash.enable = true;
              };
            };
          };
      };
    };
}
