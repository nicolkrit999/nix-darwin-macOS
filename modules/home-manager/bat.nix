{
  pkgs,
  catppuccin,
  catppuccinFlavor,
  ...
}:
{

  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (official module)
  # -----------------------------------------------------------------------
  catppuccin.bat.enable = catppuccin;
  catppuccin.bat.flavor = catppuccinFlavor;
  # -----------------------------------------------------------------------

  programs.bat = {
    enable = true;

    config = {
      # Optional: any other bat config options (like --style)
    };
  };
}
