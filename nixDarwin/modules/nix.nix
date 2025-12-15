{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # ⚙️ SYSTEM: NIX SETTINGS
  # -----------------------------------------------------------------------

  nix = {
    # ⚠️ Note: Since you use Determinate Systems installer (nix.enable = false),
    # these settings are technically ignored by the daemon. We keep them here
    # so the file structure mirrors your NixOS config.

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # ♻️ GARBAGE COLLECTION
    # 🔴 MUST BE FALSE because 'nix.enable = false'
    gc = {
      automatic = false;

      # We keep these settings here for reference,
      # but they won't run automatically on this system.
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };

    # 🔴 MUST BE FALSE because 'nix.enable = false'
    optimise.automatic = false;
  };
}
