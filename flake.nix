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
      # 🛠️ SYSTEM BUILDER (with Fallbacks)
      mkSystem =
        {
          hostname,
          user,
          # 🟢 OPTIONAL ARGUMENTS (With Defaults/Fallbacks)
          monitorConfig ? [ ], # Default to empty list
          base16Theme ? "catppuccin-macchiato",
          polarity ? "dark",
          catppuccin ? true,
          catppuccinFlavor ? "macchiato",
          catppuccinAccent ? "mauve",
          gitUserName ? "",
          gitUserEmail ? "",

          # 🖼️ DEFAULT WALLPAPER (Rain World)
          # If you don't provide a specific wallpaper for a host, this one is used.
          wallpaperURL ? "https://raw.githubusercontent.com/HyDE-Project/hyde-themes/Catppuccin-Mocha/Configs/.config/hyde/themes/Catppuccin%20Mocha/wallpapers/2%20rain_world.png",
          wallpaperSHA256 ? "0z03f4kwqc6w830pw1mlgrbpn30ljqg2m1lzrwclnd7giak2arpm",
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs user;
            # Pass variables to System modules
            inherit base16Theme polarity catppuccin;
          };
          modules = [
            # 1. Platform & Host Specifics
            { nixpkgs.hostPlatform = "aarch64-darwin"; }
            ./hosts/${hostname}/local-packages.nix

            # 2. Stylix System Module
            inputs.stylix.darwinModules.stylix

            # 3. System Configuration
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
                # Pass all variables (including defaults) to Home Manager
                inherit
                  base16Theme
                  polarity
                  catppuccin
                  catppuccinFlavor
                  catppuccinAccent
                  ;
                inherit gitUserName gitUserEmail;
                monitors = monitorConfig;
                inherit wallpaperURL wallpaperSHA256;
              };

              home-manager.users.${user} = {
                imports = [
                  ./home-manager/modules
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
        # 💻 HOST 1: KRIT (Custom Wallpaper)
        "Krits-MacBook-Pro" = mkSystem {
          hostname = "Krits-MacBook-Pro";
          user = "krit";
          monitorConfig = [ "eDP-1,3024x1964,1" ];
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";

          # Overriding the default wallpaper
          wallpaperURL = "https://raw.githubusercontent.com/HyDE-Project/hyde-themes/Catppuccin-Mocha/Configs/.config/hyde/themes/Catppuccin%20Mocha/wallpapers/2%20rain_world.png";
          wallpaperSHA256 = "0z03f4kwqc6w830pw1mlgrbpn30ljqg2m1lzrwclnd7giak2arpm";
        };

        # 💻 HOST 2: ROBERTA (Uses Defaults)
        "MacBook-Air-di-Roberta" = mkSystem {
          hostname = "MacBook-Air-di-Roberta";
          user = "krit";
          monitorConfig = [ "eDP-1,2560x1664,1" ];
          catppuccinAccent = "sky"; # Custom accent
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";

          wallpaperURL = "https://raw.githubusercontent.com/HyDE-Project/hyde-themes/Catppuccin-Mocha/Configs/.config/hyde/themes/Catppuccin%20Mocha/wallpapers/2%20rain_world.png";
          wallpaperSHA256 = "0z03f4kwqc6w830pw1mlgrbpn30ljqg2m1lzrwclnd7giak2arpm";
        };
      };
    };
}
