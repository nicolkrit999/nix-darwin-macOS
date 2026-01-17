{
  lib,
  inputs,
  vars,
  ...
}:
{
  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME
  catppuccin.alacritty.enable = vars.catppuccin;
  catppuccin.alacritty.flavor = vars.catppuccinFlavor;
  # -----------------------------------------------------------------------

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        builtin_box_drawing = true;
        normal = {
          style = lib.mkForce "Bold";
        };
      };
    };
  };
}
