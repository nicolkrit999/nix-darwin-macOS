{ pkgs, ... }:
{
  # Run Garbage Collection every week
  launchd.agents.nix-gc = {
    enable = true;
    config = {
      Label = "org.nixos.nix-gc";
      ProgramArguments = [
        "${pkgs.nix}/bin/nix-collect-garbage"
        "--delete-older-than"
        "7d"
      ];
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 2;
          Minute = 0;
        } # Sundays at 2:00 AM
      ];

      StandardOutPath = "/tmp/nix-gc.log";
      StandardErrorPath = "/tmp/nix-gc.error.log";
    };
  };
}
