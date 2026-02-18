{
  lib,
  inputs,
  vars,
  ...
}:
{
  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME
  catppuccin.alacritty.enable = vars.catppuccin or false;
  catppuccin.alacritty.flavor = vars.catppuccinFlavor or "mocha";
  # -----------------------------------------------------------------------

  programs.alacritty = {
    enable = false;
    settings = {
      window.opacity = 1.0;
      font = {
        builtin_box_drawing = true;
        normal = {
          style = lib.mkForce "Bold";
        };
      };
    };
  };
}
