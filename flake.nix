{
  description = "Krit's Nix-Darwin System Config";

  inputs = {
    # ✅ Stable 25.11 branches
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Theming
    stylix.url = "github:danth/stylix/release-25.11";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      stylix,
      catppuccin,
      ...
    }@inputs:
    let
      # ---------------------------------------------------------
      # ⚙️ GLOBAL VARIABLES
      # ---------------------------------------------------------
      user = "krit";
      system = "aarch64-darwin";

      # 🎨 THEME SETTINGS
      globalBase16Theme = "catppuccin-macchiato";
      globalPolarity = "dark";

      # 🐱 CATPPUCCIN TOGGLES
      catppuccinEnable = true;
      catppuccinFlavor = "macchiato";
      catppuccinAccent = "mauve";

      mkSystem =
        { hostname, monitorConfig }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs user; };
          modules = [
            ./modules/darwin/default.nix
            ./modules/darwin/stylix.nix
            stylix.darwinModules.stylix

            # Import Host Specific Packages
            ./hosts/${hostname}/local-packages.nix

            (
              { pkgs, ... }:
              {
                networking.hostName = hostname;
                networking.computerName = hostname;
                users.users.${user}.home = "/Users/${user}";
                system.stateVersion = 4;
              }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Pass variables to Home Manager modules
              home-manager.extraSpecialArgs = {
                inherit inputs user;
                base16Theme = globalBase16Theme;
                polarity = globalPolarity;
                catppuccin = catppuccinEnable;
                inherit catppuccinFlavor catppuccinAccent;
                monitors = monitorConfig;
                gitUserName = "nicolkrit999";
                gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
              };

              home-manager.users.${user} = {
                imports = [
                  ./modules/home-manager/default.nix
                  inputs.catppuccin.homeManagerModules.catppuccin
                  inputs.nix-index-database.hmModules.nix-index
                ];
                home.stateVersion = "24.05";
              };
            }
          ];
        };
    in

    {
      darwinConfigurations = {
        # 💻 Configuration 1: MacBook Pro (Krit)
        # Native Resolution for 14" M3 Pro is 3024x1964
        # Triggers Font Size 16.0 in Alacritty
        "Krits-MacBook-Pro" = mkSystem {
          hostname = "Krits-MacBook-Pro";
          monitorConfig = [ "eDP-1,3024x1964,1" ];
        };

        # 💻 Configuration 2: MacBook Air (Roberta)
        # Native Resolution for 13" M2 Air is 2560x1664
        # Triggers Font Size 13.0 in Alacritty
        "MacBook-Air-di-Roberta" = mkSystem {
          hostname = "MacBook-Air-di-Roberta";
          monitorConfig = [ "eDP-1,2560x1664,1" ];
        };
      };
    };
}
