{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Hardcoded for now, or you can pass these via specialArgs if you prefer
  # But usually, these are static per host logic.
  base16Theme = "catppuccin-macchiato";
  polarity = "dark";
in
{
  stylix = {
    enable = true;

    # 🎨 Base16 Scheme
    # Automatically fetches the yaml scheme from tinted-theming
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${base16Theme}.yaml";

    polarity = polarity;

    # 🖼️ Wallpaper
    # Ensure this file exists at this path!
    image = ./wallpaper.jpg;

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
        desktop = 10;
        popups = 10;
      };
    };

    # 🎯 Targets
    # Disable targets that conflict with your manual "Catppuccin" modules
    # For example, if you manage Neovim manually with Catppuccin, disable Stylix for it.
    targets = {
      neovim.enable = false; # You use your own neovim.nix
      bat.enable = false; # You use your own bat.nix
      fzf.enable = true; # Let Stylix handle generic FZF
    };
  };
}
