{
  description = "A complete, declarative macOS setup with Neovim, home manager with aliases";

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
    # Add any new machine names here to automatically generate their config
    supportedMachines = [ "MacBook-Air-di-Roberta" "Krits-MacBook-Pro" ];

    # CONFIGURATION GENERATOR
    createDarwinConfig = hostname: nix-darwin.lib.darwinSystem {
      specialArgs = { };
      modules = [
        # Include the nixpkgs and home-manager modules
        nix-index-database.darwinModules.nix-index
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
            neovim git nodejs maven gradle ripgrep fd unzip eza btop jq
            cmake docker glew glfw pandoc postgresql_14 rbenv redis sox
            speedtest-cli starship pay-respects tree yt-dlp zlib wakeonlan
            pokemon-colorscripts cloudflared tealdeer black ruff maven pyright glow
            xclip nerd-fonts.hack which universal-ctags fzf tree-sitter
            lazygit viu chafa ueberzugpp ghostscript tectonic mermaid-cli imagemagick
            kitty vimPlugins.coc-pyright jdk25
            nodePackages.vim-language-server
            nodePackages.bash-language-server
            nodePackages.yaml-language-server
            lua-language-server fastfetch pay-respects
            vimPlugins.nvim-treesitter stow ranger neo-cowsay
            vimPlugins.nvim-treesitter-parsers.regex texliveFull
            vimPlugins.nvim-java-test nerd-fonts.jetbrains-mono
            jdt-language-server

            # Define options for python3.13
            (pkgs.python313.withPackages (ps: with ps; [
              pip
              setuptools
              pynvim
              python-lsp-server
              pylsp-mypy
              isort
              python-lsp-black
              pylint
              flake8
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
            onActivation = { autoUpdate = false; upgrade = false; cleanup = "uninstall"; };
            taps = [];
            brews = ["pipes-sh"];
            casks = [ "only-switch" "pearcleaner" "font-jetbrains-mono-nerd-font"];
            user = "krit";
          };

          # Define the path of the home user.
          users.users.krit.home = "/Users/krit";
          security.pam.services.sudo_local.enable = true;
          system.primaryUser = "krit";
          system.stateVersion = 4;

          environment.shellAliases = {
            # DYNAMIC ALIAS: automatically detects hostname
            nixpush = "cd /etc/nix-darwin/ && sudo nix run nix-darwin -- switch --flake \".#$(scutil --get LocalHostName)\"";
          };
        })

        # Define general home manager behaviour
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "";
          home-manager.users.krit = import ./home.nix;
        }
      ];
    };
  in {
    # OUTPUT GENERATION
    # Generates configurations for every machine in the 'supportedMachines' list
    darwinConfigurations = nixpkgs.lib.genAttrs supportedMachines createDarwinConfig;
  };
}
