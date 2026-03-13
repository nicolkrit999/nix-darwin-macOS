{ inputs
, pkgs
, lib
, vars
, ...
}:
{
  # -----------------------------------------------------------------------
  # 👤 USER IDENTITY
  # -----------------------------------------------------------------------
  home = {
    stateVersion = vars.homeStateVersion or "25.11"; # Controls backwards compatibility logic
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # -----------------------------------------------------------------------
  # 🏠 HOME MANAGER SELF-MANAGEMENT
  # -----------------------------------------------------------------------
  programs.home-manager.enable = true;

  home.activation = {
    removeExistingConfigs = lib.hm.dag.entryBefore [ "checkLinkTargets" ] "";

    createEssentialDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] "";
  };
}
