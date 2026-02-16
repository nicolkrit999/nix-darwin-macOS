{
  vars,
  ...
}:
{

  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (official module)
  # -----------------------------------------------------------------------
  catppuccin.lazygit.enable = vars.catppuccin;
  catppuccin.lazygit.flavor = vars.catppuccinFlavor;
  catppuccin.lazygit.accent = vars.catppuccinAccent;
  # -----------------------------------------------------------------------
  programs.lazygit = {
    enable = true;

    settings = {
      # Visuals
      gui.showIcons = true; # Enables Nerd Font icons to match your terminal style
      gui.quitOnTopLevelReturn = false; # Prevents asking to go back into it after quitting
    };
  };
}
