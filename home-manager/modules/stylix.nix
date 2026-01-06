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
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${base16Theme}.yaml";
    polarity = polarity;

    opacity = {
      applications = 1.0;
      terminal = 0.90;
      desktop = 1.0;
      popups = 1.0;
    };

    # ... fonts and targets ...
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
      bat.enable = !catppuccin;
      lazygit.enable = !catppuccin;
      starship.enable = !catppuccin;
      firefox.profileNames = [ user ];
      yazi.enable = false;
    };
  };
}
