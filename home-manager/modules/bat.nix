{
  pkgs,
  vars,
  ...
}:
{

  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (official module)
  catppuccin.bat.enable = vars.catppuccin;
  catppuccin.bat.flavor = vars.catppuccinFlavor;
  # -----------------------------------------------------------------------

  programs.bat = {
    enable = true;

    config = {
    };
  };
}
