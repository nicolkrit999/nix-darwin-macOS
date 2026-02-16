{
  inputs,
  pkgs,
  lib,
  vars,
  ...
}:
{
  # -----------------------------------------------------------------------
  # 🔗 IMPORTS
  # -----------------------------------------------------------------------
  # Pulls in all individual program modules
  imports = [
    ./modules/default.nix
    ./home-packages.nix
  ];

  # -----------------------------------------------------------------------
  # 👤 USER IDENTITY
  # -----------------------------------------------------------------------
  home = {
    stateVersion = vars.homeStateVersion or "25.11"; # Controls backwards compatibility logic
  };

  # -----------------------------------------------------------------------
  # 🏠 HOME MANAGER SELF-MANAGEMENT
  # -----------------------------------------------------------------------
  programs.home-manager.enable = true;

  # -----------------------------------------------------------------------
  # 🛠️ ACTIVATION SCRIPTS
  # -----------------------------------------------------------------------
  # DESCRIPTION:
  # Scripts that run during the 'switch' process to perform tasks that
  # declarative Nix cannot do alone (like creating deep subdirectories).
  # -----------------------------------------------------------------------

  home.activation = {
    # ⚠️ Do not add ~/.config/hypr/hyprland.conf otherwise during rebuild the config change and you need to manually reapply home-manager and then logging out/in to see the changes.
    # The file need to be removed manually if needed before rebuilding
    removeExistingConfigs = lib.hm.dag.entryBefore [ "checkLinkTargets" ] "";

    createEssentialDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] "";
  };
}
