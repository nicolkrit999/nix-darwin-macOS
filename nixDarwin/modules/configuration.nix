{ pkgs, ... }:
{
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Define users group ID
  ids.gids.nixbld = 350;

  nix.enable = false;

  environment.systemPackages =
    (with pkgs; [
      # Packages in each category are sorted alphabetically

      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------
      #  ⚠️ START APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------
      ffmpegthumbnailer # Lightweight video thumbnailer (needed for ranger video previews) -> ⚠️ KEEP
      fzf # Command-line fuzzy finder (referenced in ranger.nix) -> ⚠️ KEEP
      htop # Interactive process viewer (keep to kill processes easily) -> ⚠️ KEEP
      ripgrep # Fast search tool (needed by neovim) -> ⚠️ KEEP
      # Image previews for terminal (used by Ranger backend) -> ⚠️ KEEP
      ueberzugpp
      unzip # Extraction utility for .zip files (used by mason in neovim) -> ⚠️ KEEP
      wget # File retrieval utility (used in various scripts) -> ⚠️ KEEP
      wl-clipboard # Wayland copy/paste CLI tools (needed for clipboard management) -> ⚠️ KEEP
      wtype # XTest equivalent for Wayland (simulate typing) (used in various scripts) -> ⚠️ KEEP
      zip # Compression utility for .zip files (used by mason in neovim) -> ⚠️ KEEP
      zlib # Compression utility for .zip files (used by mason in neovim) -> ⚠️ KEEP
      nixfmt-rfc-style # Nix code formatter with RFC style (used in flake.nix) -> ⚠️ KEEP

      # -----------------------------------------------------------------------------------
      # 🧑🏽‍💻 CODING
      # -----------------------------------------------------------------------------------
      vscode # Code editor (in my machine it would not installed if put in local-packages.nix) -> ⚠️ KEEP

      # -----------------------------------------------------------------------------------
      # ❓ OTHER
      # -----------------------------------------------------------------------------------
      nix-prefetch-scripts # Tools to get hashes for nix derivations (used by nixos development) -> ⚠️ KEEP

      #  ⚠️ END APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------

      #  ⭐ START OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------

      # 🖥️ DESKTOP APPLICATIONS

      # 🖥️ CLI UTILITIES
      killall # Process killer

      # 🧑🏽‍💻 CODING
      # Java Development Kit
      jdk25
      nodejs # JavaScript runtime
      (pkgs.python313.withPackages (
        ps: with ps; [
          pip
          flake8
          black
          ruff
        ]
      ))

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
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [ ];

    brews = [
      "pipes-sh"
      "nixfmt"
      "cava"

    ];

    casks = [
      "alacritty"
      "kitty"
      "iterm2"
      "pearcleaner"
      "only-switch"
      "font-jetbrains-mono-nerd-font"
      "obs"
      "telegram"
      "microsoft-teams"
      "signal"
      "vlc"
    ];
  };
}
