{ lib, pkgs, vars, ... }: {
  catppuccin.kitty.enable = vars.catppuccin;
  catppuccin.kitty.flavor = vars.catppuccinFlavor;

  programs.kitty = {
    enable = true;

    settings = {

      macos_option_as_alt = "yes";

      background_opacity = lib.mkForce "1.0";

      copy_on_select = "yes"; # automatically copy selected text to clipboard

      window_padding_width = 4;

      confirm_os_window_close = 0; # 0 = don't ask, 1 = ask

      enable_audio_bell = false;

      mouse_hide_wait =
        "3.0"; # seconds of inactivity before hiding mouse cursor
    };
  };
}
