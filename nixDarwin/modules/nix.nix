{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # ⚙️ SYSTEM: NIX SETTINGS
  # -----------------------------------------------------------------------

  nix = {
    # ⚠️ Note: Since you use Determinate Systems installer (nix.enable = false),
    # these settings are currently ignored by the daemon but kept here for
    # consistency and future-proofing.

    settings = {
      # Enable Flakes (Standard practice)
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # ♻️ GARBAGE COLLECTION
    gc = {
      automatic = true;

      # ⚠️ Mac Specific: Use 'interval' (dictionaries)
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      }; # Runs every Sunday at midnight

      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;
  };
}
