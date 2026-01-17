{
  pkgs,
  lib,
  vars,
  ...
}:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${vars.base16Theme}.yaml";
    polarity = vars.polarity;

    opacity = {
      applications = 1.0;
      terminal = 0.90;
      desktop = 1.0;
      popups = 1.0;
    };

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

    targets = {
      neovim.enable = false;

      bat.enable = !vars.catppuccin;
      lazygit.enable = !vars.catppuccin;
      starship.enable = !vars.catppuccin;
    }
    // (lib.optionalAttrs (vars.stylixExclusions != null) vars.stylixExclusions);

  };
}
