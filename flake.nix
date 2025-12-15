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
      # ---------------------------------------------------------
      # ⚙️ SYSTEM DEFINITION WRAPPER
      # ---------------------------------------------------------
      # We removed the hardcoded vars here. Now they are arguments:
      mkSystem =
        {
          hostname,
          monitorConfig,
          user, # <--- Added argument
          base16Theme, # <--- Added argument
          polarity, # <--- Added argument
          catppuccinEnable, # <--- Added argument
          catppuccinFlavor, # <--- Added argument
          catppuccinAccent, # <--- Added argument
        }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # Can also be an arg if you have Intel macs
          specialArgs = { inherit inputs user; };
          modules = [
            ./modules/darwin/default.nix

            # 🔴 REMOVED: ./modules/darwin/stylix.nix
            # (This file belongs in Home Manager because it themes user apps like bat/lazygit)

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

              # Pass the SPECIFIC variables to Home Manager modules
              home-manager.extraSpecialArgs = {
                inherit inputs user;
                base16Theme = base16Theme; # <--- Uses the arg passed to mkSystem
                polarity = polarity; # <--- Uses the arg passed to mkSystem
                catppuccin = catppuccinEnable; # <--- Uses the arg passed to mkSystem
                inherit catppuccinFlavor catppuccinAccent;
                monitors = monitorConfig;
                gitUserName = "nicolkrit999";
                gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
              };

              home-manager.users.${user} = {
                imports = [
                  ./modules/home-manager/default.nix
                  inputs.catppuccin.homeModules.catppuccin
                  inputs.nix-index-database.hmModules.nix-index

                  # 🟢 ADDED HERE:
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
          # Custom settings for this host:
          user = "krit";
          base16Theme = "catppuccin-macchiato";
          polarity = "dark";
          catppuccinEnable = true;
          catppuccinFlavor = "macchiato";
          catppuccinAccent = "mauve";
        };

        # 💻 Configuration 2: MacBook Air (Roberta)
        "MacBook-Air-di-Roberta" = mkSystem {
          hostname = "MacBook-Air-di-Roberta";
          monitorConfig = [ "eDP-1,2560x1664,1" ];
          # Roberta might want a different theme/user:
          user = "roberta"; # <--- Different user!
          base16Theme = "catppuccin-latte"; # <--- Light mode example
          polarity = "light";
          catppuccinEnable = true;
          catppuccinFlavor = "latte";
          catppuccinAccent = "blue";
        };
      };
    };
}
