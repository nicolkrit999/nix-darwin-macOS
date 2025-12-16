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
      ffmpegthumbnailer # Lightweight video thumbnailer
      fzf # Command-line fuzzy finder
      htop # Interactive process viewer
      pay-respects # Typo correction tool
      pokemon-colorscripts # Terminal styling

      ripgrep # Fast search tool
      stow # Symlink manager
      unzip # Extraction utility
      wget # File retrieval
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

      # ❓ OTHER
      bemoji # Emoji picker
      nix-prefetch-scripts # Nix dev tools

      #  ⚠️ END APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      #  ⭐ START OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------

      # 🖥️ DESKTOP APPLICATIONS
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
      qtsvg # SVG Icon support

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
      "obs" # OBS Studio
      "telegram" # Telegram Desktop
      "microsoft-teams" # Teams (Official)
      "signal" # Signal Desktop
      "vlc" # VLC Media Player
      "github" # GitHub Desktop

    ];
  };
}
