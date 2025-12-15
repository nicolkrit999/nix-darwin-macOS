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
          gitUserName,
          gitUserEmail,
          # 🆕 WALLPAPER ARGUMENTS
          wallpaperUrl,
          wallpaperSha256,
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs user;
            # Pass theme variables to System modules (if needed later)
            base16Theme = base16Theme;
            polarity = polarity;
            catppuccin = catppuccinEnable;
          };
          modules = [
            # 1. Platform & Host Specifics
            { nixpkgs.hostPlatform = "aarch64-darwin"; }
            ./hosts/${hostname}/local-packages.nix

            # 2. Stylix System Module (Required for System Fonts/Colors)
            inputs.stylix.darwinModules.stylix

            # 3. System Configuration (Your Clean Path)
            ./nixDarwin/modules

            # 4. Inline System Settings
            (
              { pkgs, ... }:
              {
                networking.hostName = hostname;
                networking.computerName = hostname;
                users.users.${user}.home = "/Users/${user}";
                system.stateVersion = 4;
                system.primaryUser = user;

                # Fix for Determinate Systems Installer
                nix.enable = false;
              }
            )

            # 5. Home Manager Configuration
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
                inherit gitUserName gitUserEmail;
                # 🆕 Pass wallpaper info to Home Manager (where stylix.nix is)
                inherit wallpaperUrl wallpaperSha256;
              };

              home-manager.users.${user} = {
                imports = [
                  # 🟢 Import User Modules
                  ./home-manager/modules

                  # 🟢 Import Plugins
                  inputs.catppuccin.homeModules.catppuccin
                  inputs.stylix.homeModules.stylix
                  inputs.nix-index-database.homeModules.nix-index
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
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";

          # 🖼️ WALLPAPER
          wallpaperURL = "https://raw.githubusercontent.com/HyDE-Project/hyde-themes/Catppuccin-Mocha/Configs/.config/hyde/themes/Catppuccin%20Mocha/wallpapers/2%20rain_world.png";
          wallpaperSHA256 = "0z03f4kwqc6w830pw1mlgrbpn30ljqg2m1lzrwclnd7giak2arpm";
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
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";

          # 🖼️ WALLPAPER
          wallpaperURL = "https://raw.githubusercontent.com/HyDE-Project/hyde-themes/Catppuccin-Mocha/Configs/.config/hyde/themes/Catppuccin%20Mocha/wallpapers/2%20rain_world.png";
          wallpaperSHA256 = "0z03f4kwqc6w830pw1mlgrbpn30ljqg2m1lzrwclnd7giak2arpm";
        };
      };
    };
}
