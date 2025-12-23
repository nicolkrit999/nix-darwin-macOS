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
      ...
    }@inputs:
    let
      # 📝 LIST OF HOSTNAMES TO BUILD
      # Add new machines here. Ensure they have a matching folder in ./hosts/
      hostNames = [
        "Krits-MacBook-Pro"
        "MacBook-Air-di-Roberta"
      ];

      # 🛠️ SYSTEM BUILDER FUNCTION
      mkSystem =
        hostname:
        let
          # 1. Import variables from the host folder
          vars = import ./hosts/${hostname}/variables.nix;
        in
        nix-darwin.lib.darwinSystem {
          # Pass variables to modules via specialArgs
          specialArgs = {
            inherit inputs;
            inherit (vars)
              user
              base16Theme
              polarity
              catppuccin
              ;
          };

          modules = [
            # 🟢 Platform Definition (From variables)
            {
              nixpkgs.hostPlatform = vars.system;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ inputs.nix-index-database.overlays.nix-index ];
            }

            # 🟢 Host Specific Packages
            ./hosts/${hostname}/local-packages.nix

            # 🟢 Host Specific Settings (Import if file exists)
            (
              if builtins.pathExists ./hosts/${hostname}/host-settings.nix then
                ./hosts/${hostname}/host-settings.nix
              else
                { }
            )

            # 🟢 System Modules
            inputs.stylix.darwinModules.stylix
            ./nixDarwin/modules

            # 🟢 User Configuration (Darwin System User)
            (
              { pkgs, ... }:
              {
                networking.hostName = hostname;
                networking.computerName = hostname;
                users.users.${vars.user}.home = "/Users/${vars.user}";
                system.stateVersion = 4;
                system.primaryUser = vars.user;
                nix.enable = false;
              }
            )

            # 🟢 Home Manager Configuration
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              # Pass variables to Home Manager modules
              home-manager.extraSpecialArgs = {
                inherit inputs;
                inherit (vars)
                  user
                  base16Theme
                  polarity
                  catppuccin
                  catppuccinFlavor
                  catppuccinAccent
                  ;
                inherit (vars)
                  gitUserName
                  gitUserEmail
                  ;
                monitors = vars.monitorConfig;
              };

              home-manager.users.${vars.user} = {
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
      # 🚀 Generate Configurations Automatically
      # This loops over 'hostNames' and calls mkSystem for each one.
      darwinConfigurations = nixpkgs.lib.genAttrs hostNames mkSystem;

      # Formatter definition
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
