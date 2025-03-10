{ pkgs, ... }: {
  imports = [ ];
  programs = {
    git.enable = false;
    # starship.enable = true;
    zsh.enable = true;
    # bash.enable = true;
  };
}
