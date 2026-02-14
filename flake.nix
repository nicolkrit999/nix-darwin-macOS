{
  description = "Krit's Nix-Darwin System Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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

    nix-sops.url = "github:Mic92/sops-nix";
    nix-sops.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      hostNames = nixpkgs.lib.attrNames (
        nixpkgs.lib.filterAttrs (
          name: type: type == "directory" && builtins.pathExists (./hosts + "/${name}/configuration.nix")
        ) (builtins.readDir ./hosts)
      );

      # 🛠️ SYSTEM BUILDER (Nix-Darwin)
      makeSystem =
        hostname:
        let
          baseVars = import ./hosts/${hostname}/variables.nix;
          hostPath = ./hosts/${hostname};
          optionalPath = hostPath + "/optional";
          modulesPath = optionalPath + "/general-hm-modules/modules.nix";

          extraVars =
            if builtins.pathExists modulesPath then
              builtins.trace "✅ [${hostname} System] Loading host HM Variables from: ${toString modulesPath}" (
                import modulesPath {
                  vars = baseVars;
                  lib = nixpkgs.lib;
                  pkgs = nixpkgs.pkgs;
                }
              )
            else
              builtins.trace
                "ℹ️ [${hostname} System] No host HM Variables module found at ${toString modulesPath}"
                { };

          hostVars = baseVars // extraVars // { inherit hostname; };
          hostHomeFile = ./hosts/${hostname}/home.nix;
          hostHomeExists = builtins.pathExists hostHomeFile;

          pkgs-unstable = import nixpkgs-unstable {
            system = hostVars.system;
            config.allowUnfree = true;
          };
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs pkgs-unstable;
            vars = hostVars;
          };
          modules = [
            # 1. Platform & Host Specifics
            {
              nixpkgs.hostPlatform = hostVars.system;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ inputs.nix-index-database.overlays.nix-index ];

              networking.hostName = hostname;
              networking.computerName = hostname;

              # 🆕 DYNAMIC VARIABLES
              system.stateVersion = hostVars.darwinStateVersion; # Using variable
              system.primaryUser = hostVars.user;

              users.users.${hostVars.user} = {
                home = "/Users/${hostVars.user}";
                uid = hostVars.uid; # Using variable
              };
            }

            ./hosts/${hostname}/configuration.nix

            (
              if builtins.pathExists optionalPath then
                builtins.trace "✅ [${hostname} System] Importing Host Optional Dir: ${toString optionalPath}" optionalPath
              else
                builtins.trace "ℹ️ [${hostname} System] No Optional Dir found." { }
            )

            inputs.stylix.darwinModules.stylix
            inputs.nix-index-database.darwinModules.nix-index
            inputs.nix-sops.darwinModules.sops

            ./nixDarwin/modules

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = false; # This solves the evaluation warning related to nixpkgs.config and/or nixpkgs.overlay in home-manager modules
              home-manager.useUserPackages = true;

              home-manager.sharedModules = [
                inputs.catppuccin.homeModules.catppuccin
                inputs.stylix.homeModules.stylix
              ];

              home-manager.extraSpecialArgs = {
                inherit inputs pkgs-unstable hostname;
                vars = hostVars;
              };

              home-manager.users.${hostVars.user} = {
                nixpkgs.config.allowUnfree = true; # Necessary if home-manager.userGlobalPkgs is false
                imports = [
                  ./home-manager/home.nix
                  ./home-manager/modules
                ]
                ++ (
                  if hostHomeExists then
                    builtins.trace "✅ [${hostname} System] Importing Host Home: ${toString hostHomeFile}" [
                      hostHomeFile
                    ]
                  else
                    [ ]
                );

                # 🆕 DYNAMIC HOME STATE VERSION
                home.stateVersion = hostVars.homeStateVersion;
              };
            }
          ];
        };

      # 🏠 HOME BUILDER (Standalone)
      makeHome =
        hostname:
        let
          baseVars = import ./hosts/${hostname}/variables.nix;
          hostPath = ./hosts/${hostname};
          optionalPath = hostPath + "/optional";
          modulesPath = optionalPath + "/general-hm-modules/modules.nix";

          extraVars =
            if builtins.pathExists modulesPath then
              builtins.trace "✅ [${hostname} Home] Loading host HM Variables from: ${toString modulesPath}" (
                import modulesPath {
                  vars = baseVars;
                  lib = nixpkgs.lib;
                  pkgs = nixpkgs.pkgs;
                }
              )
            else
              builtins.trace "ℹ️ [${hostname} Home] No host HM Variables module found." { };

          hostVars = baseVars // extraVars // { inherit hostname; };
          hostHomeFile = ./hosts/${hostname}/home.nix;

          extraModules = nixpkgs.lib.optional (builtins.pathExists hostHomeFile) (
            builtins.trace "✅ [${hostname} Home] Adding Host Home: ${toString hostHomeFile}" hostHomeFile
          );

          pkgs-unstable = import nixpkgs-unstable {
            system = hostVars.system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit (hostVars) system;
            config.allowUnfree = true;
          };

          extraSpecialArgs = {
            inherit inputs pkgs-unstable;
            vars = hostVars;
          };

          modules = [
            {
              home.username = hostVars.user;
              home.homeDirectory = "/Users/${hostVars.user}";
              # 🆕 DYNAMIC HOME STATE VERSION
              home.stateVersion = hostVars.homeStateVersion;
            }

            ./home-manager/home.nix
            ./home-manager/modules

            inputs.catppuccin.homeModules.catppuccin
            inputs.stylix.homeModules.stylix
          ]
          ++ extraModules;
        };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hostNames makeSystem;
      homeConfigurations = nixpkgs.lib.genAttrs hostNames makeHome;

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
