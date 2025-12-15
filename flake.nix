{
  description = "Krit's Nix-Darwin System Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
      mkSystem =
        {
          hostname,
          monitorConfig,
          user,
          base16Theme,
          polarity,
          catppuccinEnable,
          catppuccinFlavor,
          catppuccinAccent,
          gitUserName, # <--- 🆕 Added
          gitUserEmail, # <--- 🆕 Added
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs user; };
          modules = [
            ./modules/darwin/default.nix
            ./hosts/${hostname}/local-packages.nix
            { nixpkgs.hostPlatform = "aarch64-darwin"; }
            ./nixDarwin/modules

            (
              { pkgs, ... }:
              {
                networking.hostName = hostname;
                networking.computerName = hostname;
                users.users.${user}.home = "/Users/${user}";
                system.stateVersion = 4;
                system.primaryUser = user;

                nix.enable = false;
              }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = {
                inherit inputs user;
                base16Theme = base16Theme;
                polarity = polarity;
                catppuccin = catppuccinEnable;
                inherit catppuccinFlavor catppuccinAccent;
                monitors = monitorConfig;

                # 🆕 Pass these to Home Manager
                inherit gitUserName gitUserEmail;
              };

              home-manager.users.${user} = {
                imports = [
                  ./modules/home-manager/default.nix

                  # 🟢 Import Modules (The "Schema")
                  inputs.catppuccin.homeModules.catppuccin
                  inputs.stylix.homeModules.stylix # <--- FIXED: Explicit import here
                  inputs.nix-index-database.homeModules.nix-index

                  # 🟢 Import Your Config (The "Settings")
                  ./modules/darwin/stylix.nix
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
        "Krits-MacBook-Pro" = mkSystem {
          hostname = "Krits-MacBook-Pro";
          monitorConfig = [ "eDP-1,3024x1964,1" ];
          user = "krit";
          base16Theme = "catppuccin-macchiato";
          polarity = "dark";
          catppuccinEnable = true;
          catppuccinFlavor = "macchiato";
          catppuccinAccent = "mauve";
          # 🆕 Git Config
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
        };

        # 💻 Configuration 2: MacBook Air (Roberta)
        "MacBook-Air-di-Roberta" = mkSystem {
          hostname = "MacBook-Air-di-Roberta";
          monitorConfig = [ "eDP-1,2560x1664,1" ];
          user = "krit";
          base16Theme = "catppuccin-macchiato";
          polarity = "dark";
          catppuccinEnable = true;
          catppuccinFlavor = "macchiato";
          catppuccinAccent = "sky";
          # 🆕 Git Config
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
        };
      };
    };
}
