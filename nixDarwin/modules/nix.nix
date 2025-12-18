{ pkgs, lib, ... }:
{

  nix = {

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
