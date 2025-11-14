{
  description = "A complete, declarative macOS setup with Neovim for Java";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }: let
    system = "aarch64-darwin";
  in {
    darwinConfigurations."Krits-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      specialArgs = { };
      modules = [
        ({ pkgs, lib, ... }: {
          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true;
          programs.nix-index.enable = true;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          ids.gids.nixbld = 350;
          environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
          environment.variables.JAVA_HOME = "${pkgs.jdk23}";

          environment.systemPackages = with pkgs; [
            neovim git nodejs maven gradle ripgrep fd unzip eza btop jq
            cmake docker glew glfw pandoc postgresql_14 rbenv redis sox
            speedtest-cli starship pay-respects tree yt-dlp zlib wakeonlan
            pokemon-colorscripts cloudflared tealdeer black ruff maven pyright glow
            xclip nerd-fonts.hack which universal-ctags fzf tree-sitter
            lazygit viu chafa ueberzugpp ghostscript tectonic mermaid-cli imagemagick
            kitty vimPlugins.coc-pyright
            nodePackages.vim-language-server
            nodePackages.bash-language-server
            nodePackages.yaml-language-server
            lua-language-server fastfetch
            vimPlugins.nvim-treesitter stow vimPlugins.nvim-jdtls
            vimPlugins.nvim-treesitter-parsers.regex texliveFull
            vimPlugins.nvim-java-test nerd-fonts.jetbrains-mono
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

          programs.zsh = {
            enable = true;
            enableCompletion = true;
            promptInit = ''eval "$(starship init zsh)"'';
            shellInit = '' '';
          };

          homebrew = {
            enable = true;
            onActivation = { autoUpdate = false; upgrade = false; cleanup = "uninstall"; };
            taps = [];
            brews = [];
            casks = [ "only-switch" "pearcleaner"];
            user = "krit";
          };

          users.users.krit.home = "/Users/krit";
          security.pam.services.sudo_local.enable = true;
          system.primaryUser = "krit";
          system.stateVersion = 4;

          environment.shellAliases = {
            nixpush = "cd /etc/nix-darwin/ && sudo nix run nix-darwin -- switch --flake .#Krits-MacBook-Pro";
          };
        })
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
