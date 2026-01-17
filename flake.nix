{
  description = "Krit's nix-darwin config with multi-host + standalone Home Manager (NixOS-like builders)";

  inputs = {
    # System Inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modules / Theming
    stylix.url = "github:danth/stylix/release-25.11";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # Only treat folders that actually look like hosts as hosts
      hostNames = lib.attrNames (
        lib.filterAttrs (
          name: type:
          type == "directory"
          && builtins.pathExists (./hosts + "/${name}/variables.nix")
          && builtins.pathExists (./hosts + "/${name}/configuration.nix")
        ) (builtins.readDir ./hosts)
      );

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkPkgsUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      # -------------------------
      # 🛠️ SYSTEM BUILDER (darwin)
      # -------------------------
      makeSystem =
        hostname:
        let
          hostPath = ./hosts/${hostname};
          optionalPath = hostPath + "/optional";

          # 1) Base vars always exist
          baseVars = import (hostPath + "/variables.nix");

          # 2) Optional extra vars (your NixOS pattern)
          modulesPath = optionalPath + "/general-hm-modules/modules.nix";
          extraVars =
            if builtins.pathExists modulesPath then import modulesPath { vars = baseVars; } else { };

          hostVars = baseVars // extraVars // { inherit hostname; };

          pkgs-unstable = mkPkgsUnstable hostVars.system;

          # Optional host-wide modules folder (requires optional/default.nix)
          optionalModule = if builtins.pathExists optionalPath then optionalPath else { };

          # Optional HM extras
          hmGeneralPath = optionalPath + "/general-hm-modules/home.nix";
          hmHostFolder = optionalPath + "/host-hm-modules";
          hmExtraImports =
            lib.optional (builtins.pathExists hmGeneralPath) hmGeneralPath
            ++ lib.optional (builtins.pathExists hmHostFolder) hmHostFolder;
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs pkgs-unstable;
            vars = hostVars;
          };

          modules = [
            # Inline “base” module (like your NixOS builder)
            {
              nixpkgs.hostPlatform = hostVars.system;
              nixpkgs.config.allowUnfree = true;

              # Optional overlay (keep if you rely on it)
              nixpkgs.overlays = [
                inputs.nix-index-database.overlays.nix-index
              ];

              networking.hostName = hostname;
              networking.computerName = hostname;

              # Required for user-scoped defaults in recent nix-darwin
              system.primaryUser = hostVars.user;

              # Ensure HM can infer homeDirectory when embedded
              users.users.${hostVars.user}.home = "/Users/${hostVars.user}";
            }

            # Your host config (imports common-configuration etc.)
            (hostPath + "/configuration.nix")

            # Optional host folder (if you keep a default.nix there)
            optionalModule

            # Flake-provided darwin modules
            inputs.nix-sops.darwinModules.sops
            inputs.stylix.darwinModules.stylix
            inputs.nix-index-database.darwinModules.nix-index

            # Your shared nix-darwin modules folder
            ./nixDarwin/modules

            # Home Manager (embedded)
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Make these modules available across HM (NixOS-like sharedModules)
              home-manager.sharedModules = [
                inputs.catppuccin.homeModules.catppuccin
                inputs.stylix.homeModules.stylix
                inputs.nix-sops.homeManagerModules.sops
              ];

              home-manager.extraSpecialArgs = {
                inherit inputs pkgs-unstable;
                vars = hostVars;
              };

              home-manager.users.${hostVars.user} = {
                imports = [
                  ./home-manager/home.nix
                ]
                ++ hmExtraImports;
              };
            }
          ];
        };

      # -------------------------
      # 🏠 HOME BUILDER (standalone)
      # -------------------------
      makeHome =
        hostname:
        let
          hostPath = ./hosts/${hostname};
          optionalPath = hostPath + "/optional";

          baseVars = import (hostPath + "/variables.nix");

          modulesPath = optionalPath + "/general-hm-modules/modules.nix";
          extraVars =
            if builtins.pathExists modulesPath then import modulesPath { vars = baseVars; } else { };

          hostVars = baseVars // extraVars // { inherit hostname; };

          pkgs = mkPkgs hostVars.system;
          pkgs-unstable = mkPkgsUnstable hostVars.system;
          optionalModule = if builtins.pathExists optionalPath then optionalPath else { };

          hmGeneralPath = optionalPath + "/general-hm-modules/home.nix";
          hmHostFolder = optionalPath + "/host-hm-modules";
          hmExtraImports =
            lib.optional (builtins.pathExists hmGeneralPath) hmGeneralPath
            ++ lib.optional (builtins.pathExists hmHostFolder) hmHostFolder;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs pkgs-unstable;
            vars = hostVars;
          };

          modules = [
            # Standalone HM needs these explicitly (your home.nix doesn’t set them)
            {
              home.username = hostVars.user;
              home.homeDirectory = "/Users/${hostVars.user}";
              home.stateVersion = hostVars.homeStateVersion;
            }

            # Your base HM config
            ./home-manager/home.nix

            # Shared HM modules (same as embedded)
            inputs.catppuccin.homeModules.catppuccin
            inputs.stylix.homeModules.stylix
            inputs.nix-sops.homeManagerModules.sops
          ]
          ++ hmExtraImports;
        };
    in
    {
      darwinConfigurations = lib.genAttrs hostNames makeSystem;
      homeConfigurations = lib.genAttrs hostNames makeHome;

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;
    };
}
