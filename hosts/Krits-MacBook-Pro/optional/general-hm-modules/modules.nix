{ vars, ... }:
let
  # Allow to use variables despite flake.nix use this to create variables
  rawVars = import ../../variables.nix;
in
{

  stylixExclusions = {
    # Strictly false
    yazi.enable = false;

    # Strictly true
    cava.enable = true;

    # Catppuccin variable-based
    kitty.enable = !vars.catppuccin;
    alacritty.enable = !vars.catppuccin;

    # Other
  };

  nixImpure = true;

  useFahrenheit = false;
}
