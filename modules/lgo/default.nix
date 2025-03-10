{ pkgs, ... }: {
  imports = [ ];
  programs = {
    git.enable = true;
    starship.enable = true;
    bash.enable = true;
  };
}
