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
          user,
          monitorConfig ? [ ], # Default to empty list
          base16Theme ? "catppuccin-macchiato",
          polarity ? "dark",
          catppuccin ? false,
          catppuccinFlavor ? "macchiato",
          catppuccinAccent ? "mauve",
          gitUserName ? "",
          gitUserEmail ? "",
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs user;
            inherit base16Theme polarity catppuccin;
          };
          modules = [
            # 1. Platform & Host Specifics
            {
              nixpkgs.hostPlatform = "aarch64-darwin";

              nixpkgs.config.allowUnfree = true;

              nixpkgs.overlays = [
                inputs.nix-index-database.overlays.nix-index
              ];
            }
            ./hosts/${hostname}/local-packages.nix

            # Import smart if the host-specific settings file exists
            (
              if builtins.pathExists ./hosts/${hostname}/host-settings.nix then
                ./hosts/${hostname}/host-settings.nix
              else
                { }
            )

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
                inherit base16Theme polarity;
                # Map catppuccin to catppuccin for modules
                catppuccin = catppuccin;
                inherit catppuccinFlavor catppuccinAccent;
                inherit gitUserName gitUserEmail;
                monitors = monitorConfig;
              };

              home-manager.users.${user} = {
                imports = [
                  ./home-manager/modules
                  inputs.catppuccin.homeModules.catppuccin
                  inputs.stylix.homeModules.stylix
                ];
                home.stateVersion = "24.05";
              };
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        # 💻 HOST 1: KRIT
        "Krits-MacBook-Pro" = mkSystem {
          hostname = "Krits-MacBook-Pro";
          user = "krit";
          monitorConfig = [ "eDP-1,3024x1964,1" ]; # The identifier is always eDP-1 on MacBooks (at least i think)
          base16Theme = "nord";
          polarity = "dark";
          catppuccin = false;
          catppuccinFlavor = "macchiato";
          catppuccinAccent = "mauve";
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
        };

        # 💻 HOST 2: ROBERTA
        "MacBook-Air-di-Roberta" = mkSystem {
          hostname = "MacBook-Air-di-Roberta";
          user = "krit";
          monitorConfig = [ "eDP-1,2560x1664,1" ]; # The identifier is always eDP-1 on MacBooks (at least i think)
          base16Theme = "nord";
          polarity = "dark";
          catppuccin = false;
          catppuccinFlavor = "macchiato";
          catppuccinAccent = "mauve";
          gitUserName = "nicolkrit999";
          gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
