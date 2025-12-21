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

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Build users group ID (from your old config)
  ids.gids.nixbld = 350;

  nix.enable = false;
  environment.systemPackages =
    (with pkgs; [
      # Packages in each category are sorted alphabetically

      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------
      #  ⚠️ START APPLICATIONS TO KEEP HERE BLOCK ⚠️

      # -----------------------------------------------------------------------------------
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------
      # Lightweight video thumbnailer (needed for ranger video previews) -> ⚠️ KEEP
      ffmpegthumbnailer
      fzf # Command-line fuzzy finder (ls zhs aliases depend on this) -> ⚠️ KEEP
      htop # Interactive process viewer (keep to kill processes easily) -> ⚠️ KEEP
      nh # CLI help for Nix package management (used in zsh.nix) -> ⚠️ KEEP
      ueberzugpp # Image previews for terminal (used by Ranger backend) -> ⚠️ KEEP
      nixfmt-rfc-style # Nix code formatter with RFC style (used in flake.nix) -> ⚠️ KEEP

      # -----------------------------------------------------------------------------------
      # 🧑🏽‍💻 CODING
      # -----------------------------------------------------------------------------------
      vscode # Code editor (in my machine it would not installed if put in local-packages.nix) -> ⚠️ KEEP

      # -----------------------------------------------------------------------
      # ❓ OTHER
      # -----------------------------------------------------------------------
      nix-prefetch-scripts # Nix dev tools

      #  ⚠️ END APPLICATIONS TO KEEP HERE BLOCK ⚠️
      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------
      #  ⭐ START OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------
      wakeonlan # Magic packet
      croc # File transfer
      tealdeer # tldr implementation
      ttyd # Terminal over web
      killall # Process killer
      ripgrep # Fast line-oriented search tool (needed by neovim) -> ⚠️ KEEP
      wget # File retrieval utility (used in various scripts) -> ⚠️ KEEP
      unzip # Extraction utility for .zip files (used by mason in neovim) -> ⚠️ KEEP
      zip # Compression utility
      zlib # Compression utility

      # -----------------------------------------------------------------------------------
      # 🧑🏽‍💻 CODING
      # -----------------------------------------------------------------------------------
      # Java Development Kit (needed for some Neovim LSP servers) -> ⚠️ KEEP
      jdk25
      nodejs # JavaScript runtime (needed for some Neovim plugins and LSP servers) -> ⚠️ KEEP
      (pkgs.python313.withPackages (
        ps: with ps; [
          pip # Package installer for Python
          flake8 # Style guide enforcement
          black # The uncompromising code formatter
          ruff # Extremely fast Python linter
        ]
      ))

      # -----------------------------------------------------------------------------------
      # 😂 FUN PACKAGES
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------
      # ❓ OTHER
      # -----------------------------------------------------------------------
      bemoji # Emoji picker

      #  ⭐ END OF OTHER APPLICATION ⭐
      # -----------------------------------------------------------------------------------
      # -----------------------------------------------------------------------------------

    ])
    # 2. 🔗 Connect the second list using ++
    ++ (with pkgs.kdePackages; [
      # ---------------------------------------------------
      # 🐬 KDE PACKAGES
      # ---------------------------------------------------
      qtsvg # SVG Icon support

      # Fonts support (Using pkgs because they are not in kdePackages)
      pkgs.inter # Used in stylix.nix -> ⚠️ KEEP
      pkgs.noto-fonts # Used in configuration.nix -> ⚠️ KEEP
      pkgs.nerd-fonts.jetbrains-mono # Used in various places -> ⚠️ KEEP
    ]);
}
