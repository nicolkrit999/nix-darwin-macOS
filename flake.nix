{
  description = "A complete, declarative macOS setup with Neovim, home manager with aliases";

  # Define from where the packages are installed
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Define that all installed packages are from the unstable channel (the more update one)
    nix-darwin.url = "github:LnL7/nix-darwin"; # Nix-darwing url fetch
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs"; # Define that nix-darwin uses the regular nix packages

    # Home-manager module support
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Define outputs
  outputs = { self, nixpkgs, nix-darwin, home-manager }: let
    system = "aarch64-darwin"; # Define that the system is aarch64 based on darwin
  in {
    # Define hostname
    darwinConfigurations."Krits-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      specialArgs = { };

      # Define nix enabled modules and various options
      modules = [
        ({ pkgs, lib, ... }: {
          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true; # Allow allowUnfree packages

          # Allow insecured packages, for example older not maintained version
          nixpkgs.config.permittedInsecurePackages = [
          ];
          programs.nix-index.enable = true;
          nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Define experimental feature, enable support for flakes and cli nix commands
          ids.gids.nixbld = 350;
          environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ]; # Define homebrew as systemPath
          environment.variables.JAVA_HOME = "${pkgs.jdk25}"; # Set the installed java packages in the environment variable JAVA_HOME. Useful to take it in setup like neovim
          environment.variables.JDTLS_BIN = "${pkgs.jdt-language-server}/bin/jdtls"; # Override default jdtls, for example to tell neovim to use the installed one instead of installing an older version


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
            promptInit = ''eval "$(starship init zsh)"; eval "$(pay-respects zsh --alias)"'';
            shellInit = '' '';
          };


          # Define installed homebrew packages
          homebrew = {
            enable = true;
            onActivation = { autoUpdate = false; upgrade = false; cleanup = "uninstall"; };
            taps = [];
            brews = ["pipes-sh"];
            casks = [ "only-switch" "pearcleaner"];
            user = "krit";
          };

          # Define the path of the home user. It need to match the related section in home manager (home.nix)
          users.users.krit.home = "/Users/krit";
          security.pam.services.sudo_local.enable = true;
          system.primaryUser = "krit";
          system.stateVersion = 4;

          environment.shellAliases = {
            nixpush = "cd /etc/nix-darwin/ && sudo nix run nix-darwin -- switch --flake .#Krits-MacBook-Pro";
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
  };
}
