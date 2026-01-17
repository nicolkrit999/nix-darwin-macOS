{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;

    # Sunday 02:00 (launchd StartCalendarInterval semantics)
    interval = {
      Weekday = 0;
      Hour = 2;
      Minute = 0;
    };

    # passed to nix-collect-garbage
    options = "--delete-older-than 7d";
  };
}
