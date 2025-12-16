{
  pkgs,
  lib,
  ...
}:
{
  # 🟢 Install Chafa as a fallback image viewer (CLI based)
  # This is useful for Alacritty or over SSH where graphical previews fail
  home.packages = [ pkgs.chafa ];

  programs.ranger = {
    enable = true;

    # -----------------------------------------------------
    # ⌨️ KEY MAPPINGS
    # -----------------------------------------------------
    mappings = {
      e = "edit";
      ec = "compress";
      ex = "extract";
      b = "fzm";
      "." = "set show_hidden!";
    };

    # -----------------------------------------------------
    # ⚙️ PROGRAM SETTINGS
    # -----------------------------------------------------
    settings = {
      # 🖼️ IMAGE PREVIEWS
      # Alacritty (macOS): Fails (no support).
      # Kitty (macOS): Works natively!
      #
      # Setting this to 'true' and method to 'kitty' enables native previews
      # when running inside Kitty. When in Alacritty, it simply won't show them
      # (or you can use 'i' to preview with Chafa manually if configured).
      preview_images = true;
      preview_images_method = "kitty";

      draw_borders = true;
      w3m_delay = 0;
    };

    extraConfig = ''
      default_linemode devicons2
    '';

    plugins = [
      {
        name = "ranger-archives";
        src = builtins.fetchGit {
          url = "https://github.com/maximtrp/ranger-archives";
          ref = "master";
          rev = "b4e136b24fdca7670e0c6105fb496e5df356ef25";
        };
      }
      {
        name = "ranger-devicons2";
        src = builtins.fetchGit {
          url = "https://github.com/cdump/ranger-devicons2";
          ref = "master";
          rev = "94bdcc19218681debb252475fd9d11cfd274d9b1";
        };
      }
      {
        name = "ranger_tmux";
        src = builtins.fetchGit {
          url = "https://github.com/joouha/ranger_tmux";
          ref = "master";
          rev = "05ba5ddf2ce5659a90aa0ada70eb1078470d972a";
        };
      }
    ];
  };

  # 🟢 WRAPPED THIS IN LINUX CHECK
  # (Desktop entries are for Linux XDG menus only)
  xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
    ranger = {
      name = "Ranger";
      genericName = "File Manager";
      exec = "alacritty -e ranger";
      terminal = false;
      categories = [
        "System"
        "FileTools"
        "FileManager"
      ];
      mimeType = [ "inode/directory" ];
    };
  };
}
