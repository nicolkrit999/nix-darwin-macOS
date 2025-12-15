{
  catppuccin,
  catppuccinFlavor,
  catppuccinAccent,
  ...
}:
{

  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (official module)
  # -----------------------------------------------------------------------
  catppuccin.lazygit.enable = catppuccin;
  catppuccin.lazygit.flavor = catppuccinFlavor;
  catppuccin.lazygit.accent = catppuccinAccent;
  # -----------------------------------------------------------------------
  programs.lazygit = {
    enable = true;

    settings = {
      # Visuals
      gui.showIcons = true; # Enables Nerd Font icons to match your terminal style
    };
  };
}
