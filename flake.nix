{
  description = "Personal nix darwing configuration, including mac specific zshrc options, and source for dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-index-database }: let

    # SYSTEM ARCHITECTURE
    system = "aarch64-darwin";

    # HOSTNAMES LIST
    supportedMachines = [ "MacBook-Air-di-Roberta" "Krits-MacBook-Pro" ];

    # CONFIGURATION GENERATOR
    createDarwinConfig = hostname: nix-darwin.lib.darwinSystem {
      specialArgs = { };
      modules = [
        # Include the nixpkgs and home-manager modules
        ({ pkgs, lib, ... }: {

          # DYNAMIC HOSTNAME CONFIGURATION
          networking.hostName = hostname;
          networking.computerName = hostname;
          documentation.enable = false;
          nix.enable = false;
          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true;

          nixpkgs.config.permittedInsecurePackages = [
          ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          ids.gids.nixbld = 350;
          environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

          environment.variables.JAVA_HOME = "${pkgs.jdk25}";
          environment.variables.JDTLS_BIN = "${pkgs.jdt-language-server}/bin/jdtls";

          # General nix packages installation
          environment.systemPackages = with pkgs; [
            # ---------------------------------------------------
            # 1. CORE SYSTEM UTILITIES & SHELL ENHANCEMENTS
            # ---------------------------------------------------
            starship        # Customizable shell prompt
            eza             # Modern replacement for 'ls'
            btop            # Resource monitor (better 'top')
            ripgrep         # Ultra-fast replacement for 'grep'
            fd              # User-friendly replacement for 'find'
            fzf             # Command-line fuzzy finder
            zlib            # Compression library (required by many system tools)
            unzip           # Tool to extract zip files
            which           # Locate a command
            tree            # Display directories as a tree
            stow            # Symlink farm manager (used for dotfiles)
            ranger          # Console file manager with VI keybindings
            tealdeer        # Fast implementation of tldr (simplified man pages)
            xclip           # Command line interface to X selections (clipboard)
            wakeonlan       # Tool to send magic packets to wake devices

            # ---------------------------------------------------
            # 2. DEVELOPMENT TOOLS & VERSION CONTROL
            # ---------------------------------------------------
            git             # Distributed version control system
            lazygit         # Simple terminal UI for git commands
            cmake           # Cross-platform build system
            docker          # Containerization platform
            universal-ctags # Tool to generate index (tags) files of source code
            jq              # Command-line JSON processor
            glow            # Markdown renderer for the terminal
            grex            # Command-line tool for generating regular expressions

            # ---------------------------------------------------
            # 3. NEOVIM & EDITOR SUPPORT
            # ---------------------------------------------------
            neovim          # Hyperextensible Vim-based text editor
            tree-sitter     # Incremental parsing system (core for syntax highlighting)
            # Neovim Plugins (System Level)
            vimPlugins.coc-pyright                  # Python support for CoC
            vimPlugins.nvim-treesitter              # Treesitter configurations
            vimPlugins.nvim-treesitter-parsers.regex # Regex parser for treesitter
            vimPlugins.nvim-java-test               # Java testing support
            # Fonts
            nerd-fonts.hack           # Hack font with icons
            nerd-fonts.jetbrains-mono # JetBrains Mono with icons

            # ---------------------------------------------------
            # 4. LANGUAGES, RUNTIMES & BUILD TOOLS
            # ---------------------------------------------------
            # Java
            jdk25                   # Java Development Kit 25
            maven                   # Build automation tool for Java
            gradle                  # Build automation tool for multi-language
            jdt-language-server     # Java language server (LSP)

            # Node / Web
            nodejs                  # JavaScript runtime
            nodePackages.vim-language-server  # LSP for Vim script
            nodePackages.bash-language-server # LSP for Bash
            nodePackages.yaml-language-server # LSP for YAML

            # C/C++ Libraries
            glew                    # OpenGL Extension Wrangler Library
            glfw                    # Multi-platform library for OpenGL/Vulkan

            # Other Languages
            lua-language-server     # LSP for Lua
            rbenv                   # Ruby version manager
            postgresql_14           # PostgreSQL database client/server
            redis                   # In-memory data store
            pyright                 # Static type checker for Python

            # ---------------------------------------------------
            # 5. DOCUMENT PROCESSING & MEDIA
            # ---------------------------------------------------
            pandoc          # Universal markup converter (docs/markdown/etc)
            tectonic        # Modernized, complete, self-contained TeX/LaTeX engine
            texliveFull     # The complete TeX Live distribution (Note: Large download)
            mermaid-cli     # CLI for generating diagrams from Mermaid code
            ghostscript     # Interpreter for PostScript and PDF
            imagemagick     # Image manipulation library
            sox             # "Swiss Army knife" of sound processing
            yt-dlp          # Command-line audio/video downloader

            # Image Viewers in Terminal
            viu             # Terminal image viewer
            chafa           # Terminal graphics (images to text/sixel)
            ueberzugpp      # C++ port of ueberzug (images in terminal)

            # ---------------------------------------------------
            # 6. NETWORKING & INTERNET
            # ---------------------------------------------------
            cloudflared     # Cloudflare Tunnel client
            speedtest-cli   # Command line interface for testing internet bandwidth
            croc            # Securely and easily send files between two computers
            ttyd            # Share your terminal over the web

            # ---------------------------------------------------
            # 7. FUN, VISUALS & TERMINAL TOYS
            # ---------------------------------------------------
            pay-respects            # Typo correction tool (Press F)
            fastfetch               # System information fetcher (faster neofetch)
            pokemon-colorscripts    # Prints random pokemon on start
            neo-cowsay              # Cowsay reborn (ASCII art with text)
            cbonsai                 # Grow bonsai trees in your terminal
            asciinema               # Record and share terminal sessions
            kitty                   # GPU-based terminal emulator

            # ---------------------------------------------------
            # 8. PYTHON ENVIRONMENT (Bundled with Packages)
            # ---------------------------------------------------
            (pkgs.python313.withPackages (ps: with ps; [
              pip                 # Package installer for Python
              setuptools          # Library for packaging Python projects
              pynvim              # Python client for Neovim
              python-lsp-server   # Python LSP (pylsp)
              python-lsp-black    # Black formatting support for pylsp
              pylsp-mypy          # Mypy type checking for pylsp
              isort               # Sort imports alphabetically
              pylint              # Source code analyzer
              flake8              # Style guide enforcement
              black               # The uncompromising code formatter
              ruff                # Extremely fast Python linter
              faker               # Generate fake data
            ]))
          ];

          # Tell zsh to eval the necessary packages
          programs.zsh = {
            enable = true;
            enableCompletion = true;
            promptInit = "";
          };

          # Define installed homebrew packages
          homebrew = {
            enable = true;

            # ---------------------------------------------------
            # BEHAVIOR CONFIGURATION
            # ---------------------------------------------------
            onActivation = {
              autoUpdate = false;      # Don't update Homebrew every time nix-darwin runs
              upgrade = false;         # Don't automatically upgrade packages (faster builds)
              cleanup = "uninstall";   # Uninstall any brew package not listed here (Declarative)
            };

            user = "krit";             # The user needed to run Homebrew commands

            # ---------------------------------------------------
            # TAPS (Third-party Repositories)
            # ---------------------------------------------------
            taps = [
              # "homebrew/cask-fonts"  # Example: If you need specific font versions
            ];

            # ---------------------------------------------------
            # BREWS (CLI Tools managed by Homebrew)
            # ---------------------------------------------------
            # Use this for tools that are broken or missing in Nixpkgs
            brews = [
              "pipes-sh"               # Animated pipes terminal screensaver (Visual toy)
            ];

            # ---------------------------------------------------
            # CASKS (GUI Applications & Fonts)
            # ---------------------------------------------------
            # macOS native apps that are easier to install via Homebrew
            casks = [
              # Utilities
              "only-switch"                    # All-in-one menu bar toggle (Dark mode, Hide notch, etc.)
              "pearcleaner"                    # Free, open-source app uninstaller and cleaner

              # Fonts
              # (Note: You also have this in systemPackages, usually one is enough)
              "font-jetbrains-mono-nerd-font"  # JetBrains Mono font patched with Nerd icons
            ];
          };

          # Define the path of the home user.
          users.users.krit.home = "/Users/krit";

          # --- TOUCH ID ENABLED HERE ---
          security.pam.services.sudo_local = {
            enable = true;
            touchIdAuth = true;
          };
          # -----------------------------

          system.primaryUser = "krit";
          system.stateVersion = 4;

          environment.shellAliases = {
            # DYNAMIC ALIAS: automatically detects hostname
            nixpush = "cd ~/nix-config/ && sudo nix run nix-darwin -- switch --flake \".#$(scutil --get LocalHostName)\"";
          };
        })

        # Define general home manager behaviour
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "";

          # --- FIXED HOME MANAGER SECTION ---
          # (Restored the logic that fixes the nix-index prompt)
          home-manager.users.krit = { ... }: {
            imports = [
              ./home.nix
              nix-index-database.hmModules.nix-index
            ];

            programs.nix-index = {
              enable = true;
              enableZshIntegration = false; # Disables the annoying prompt
            };
          };
          # --------------------------------
        }
      ];
    };
  in {
    # OUTPUT GENERATION
    darwinConfigurations = nixpkgs.lib.genAttrs supportedMachines createDarwinConfig;
  };
}
