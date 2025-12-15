{
  pkgs,
  base16Theme,
  polarity,
  catppuccin,
  user,
  ...
}:
{
  stylix = {
    enable = true;
    # 🎨 General Theme Settings
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${base16Theme}.yaml";
    image = ./wallpaper.jpg; # (Make sure wallpaper.jpg is in this folder!)
    polarity = polarity;

    opacity = {
      applications = 1.0;
      terminal = 0.90;
      desktop = 1.0;
      popups = 1.0;
    };

    # 🅰️ Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        applications = 12;
        terminal = 14;
        desktop = 12;
        popups = 10;
      };
    };

    # 🎯 Targets (Now valid because this is Home Manager!)
    targets = {
      neovim.enable = false;
      bat.enable = !catppuccin;
      fzf.enable = !catppuccin;
      lazygit.enable = !catppuccin;

      # Firefox Profile
      firefox.profileNames = [ user ];
    };
  };
}
