# How to Use:
1. Add Users: Add the desired usernames to the `userNames` list.
2. Create User Modules: Define the configurations for each user in the `flake.homeModules` section (e.g., `lgo`, `otheruser`, `newuser`, etc.).
3. Apply the Configuration:
   - For home-manager stand-alone, use the command: `home-manager --flake .#lgo switch` or `home-manager --flake .#otheruser switch`.
   - For NixOS users, you'll need to refer to your new configurations in your NixOS configuration. That would be something like this:
``` nix
# /etc/nixos/configuration.nix
{ pkgs, ... }:
{
    # ... other parts ...

    imports = [
        ./hardware-configuration.nix
        # ... other modules ...
        inputs.gohome.nixosModules.default # gohome is the name of the folder that contains your flake.nix
    ];
    users.users = {
        lgo = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        };
        otheruser = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        };
    };
    home-manager.users = {
        lgo = inputs.gohome.legacyPackages."${pkgs.system}".homeConfigurations.lgo;
        otheruser = inputs.gohome.legacyPackages."${pkgs.system}".homeConfigurations.otheruser;
    };

    # ... other parts ...
}
```
