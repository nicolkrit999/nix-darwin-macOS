{ pkgs, ... }:
{
  # ---------------------------------------------------
  # 1. SYSTEM SETTINGS & DEFAULTS
  # ---------------------------------------------------
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # Enable Touch ID for sudo (Saved you from typing passwords!)
  security.pam.services.sudo_local.touchIdAuth = true;

  # Build users group ID (from your old config)
  ids.gids.nixbld = 350;

  nix.enable = false;

  # ---------------------------------------------------
  # 2. SYSTEM PACKAGES (Restored your Full List)
  # ---------------------------------------------------
  environment.systemPackages =
    (with pkgs; [
      # Packages in each category are sorted alphabetically

      # -----------------------------------------------------------------------------------
      #  ⚠️ START APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------

      # 🖥️ DESKTOP APPLICATIONS
      mpv # Video player
      vesktop # Discord client
      vscode # Code editor

      # 🖥️ CLI UTILITIES
      brightnessctl # Control device backlight
      cliphist # Wayland clipboard history
      ffmpegthumbnailer # Lightweight video thumbnailer
      fzf # Command-line fuzzy finder
      grimblast # Wayland screenshot helper
      htop # Interactive process viewer
      hyprpicker # Wayland color picker
      pay-respects # Typo correction tool
      playerctl # Control media players
      pokemon-colorscripts # Terminal styling

      ripgrep # Fast search tool
      showmethekey # Keyboard visualizer
      stow # Symlink manager
      ueberzugpp # Image previews
      unzip # Extraction utility
      wget # File retrieval
      wl-clipboard # Wayland copy/paste
      wtype # Wayland xdotool
      zip # Compression utility
      zlib # Compression utility

      # 🧑🏽‍💻 CODING
      jdk25 # Java Development Kit
      nodejs # JavaScript runtime
      (pkgs.python313.withPackages (
        ps: with ps; [
          pip
          flake8
          black
          ruff
        ]
      ))

      # 🪟 WINDOW MANAGER (WM) INFRASTRUCTURE
      libnotify # Notifications
      xdg-desktop-portal-gtk # File pickers
      xdg-desktop-portal-hyprland # Screen sharing

      # ❓ OTHER
      bemoji # Emoji picker
      nix-prefetch-scripts # Nix dev tools

      #  ⚠️ END APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      #  ⭐ START OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------

      # 🖥️ DESKTOP APPLICATIONS
      kdePackages.audiotube # Youtube music
      wakeonlan # Magic packets

      # 🖥️ CLI UTILITIES
      croc # File transfer
      tealdeer # tldr implementation
      ttyd # Terminal over web
      nixfmt-rfc-style # Nix formatter
      killall # Process killer

      #  ⭐ END OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------
    ])
    # 2. 🔗 Connect the second list using ++
    ++ (with pkgs.kdePackages; [
      # ---------------------------------------------------
      # 🐬 KDE PACKAGES
      # ---------------------------------------------------
      dolphin # File manager
      qtsvg # SVG Icon support
      kio-fuse # Mount remote filesystems
      kio-extras # Extra protocols

      # Fonts support (Using pkgs because they are not in kdePackages)
      pkgs.inter
      pkgs.noto-fonts
      pkgs.nerd-fonts.jetbrains-mono
    ]);

  # ---------------------------------------------------
  # 3. HOMEBREW CONFIGURATION
  # ---------------------------------------------------
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "uninstall"; # Restored your declarative cleanup
    };

    taps = [ ];

    brews = [
      "pipes-sh"
      "nixfmt"
    ];

    casks = [
      "alacritty"
      "kitty"
      "iterm2"
      "pearcleaner"
      "only-switch"
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
