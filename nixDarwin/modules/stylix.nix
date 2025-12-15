{
  pkgs,
  lib,
  base16Theme, # Passed from flake.nix
  polarity, # Passed from flake.nix
  catppuccin, # Passed from flake.nix (bool)
  user,
  ...
}:
{
  stylix = {
    enable = true;

    # 🎨 Base16 Scheme
    # Uses the dynamic variable passed from your host config
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${base16Theme}.yaml";

    image = ./wallpaper.jpg; # Ensure this file exists!

    # 🌗 Polarity (dark/light)
    polarity = polarity;

    # 🖱️ Cursor
    # macOS manages its own cursor. Disabling this prevents build warnings.
    cursor = {
      package = pkgs.bibata-cursors; # Just in case a Linux app needs it
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    # 🅰️ Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sizes = {
        applications = 12;
        terminal = 14;
        desktop = 12;
        popups = 10;
      };
    };

    # 🎯 Targets
    # LOGIC: If 'catppuccin' is true, disable Stylix for these apps
    # so the official Catppuccin module can theme them instead.
    targets = {
      # Neovim: You usually manage this manually, so always disable Stylix
      neovim.enable = false;

      # Bat: If catppuccin module is ON, turn Stylix OFF.
      bat.enable = !catppuccin;

      # FZF: If catppuccin module is ON, turn Stylix OFF.
      fzf.enable = !catppuccin;

      # Lazygit: Same logic
      lazygit.enable = !catppuccin;

      firefox.profileNames = [ user ];
    };
  };
}
