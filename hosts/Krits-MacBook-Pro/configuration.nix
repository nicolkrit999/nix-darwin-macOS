{ pkgs, config, vars, ... }: {
  imports = [
    # Common krit modules
    # This import common system-wide modules
    ../../common/krit/modules/default.nix
    ../../common/krit/modules/system/nas/default.nix

    # Local modules
    ./optional/default.nix
  ];

  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # 🔐 SOPS CONFIGURATION
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # 1. DEFAULT SOURCE (Host Specific)
  environment.variables = {
    SOPS_AGE_KEY_FILE = "/Users/krit/.config/sops/age/keys.txt";
  };

  sops.defaultSopsFile =
    ./optional/host-sops-nix/Krits-MacBook-Pro-secrets-sops.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/Users/krit/.config/sops/age/keys.txt";
  sops.environment.SOPS_AGE_KEY_FILE = "/Users/krit/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];

  # 2. GLOBAL SECRETS DEFINITION
  sops.secrets =
    let commonSecrets = ../../common/krit/sops/krit-common-secrets-sops.yaml;
    in {
      # LOCAL SECRETS:
      # Loc-1. Local User password

      # COMMON SECRETS:
      # Comm-3
      github_fg_pat_token_nix = {
        sopsFile = commonSecrets;
        mode = "0444";
      };
      # Comm-1
      github_general_ssh_key = {
        sopsFile = commonSecrets;
        owner = vars.user;
        path = "/Users/${vars.user}/.ssh/id_github";
        mode = "0600";
      };

      # Comm-4
      Krit_Wifi_pass = { sopsFile = commonSecrets; };
      Nicol_5Ghz_pass = { sopsFile = commonSecrets; };
      Nicol_2Ghz_pass = { sopsFile = commonSecrets; };
    };

  # Tell Nix to read the Github token
  nix.extraOptions = ''
    !include ${config.sops.secrets.github_fg_pat_token_nix.path}
  '';
  # ---------------------------------------------------------
  # 🔧 CONFIGURE SSH TO USE THE KEY
  # ---------------------------------------------------------
  programs.ssh = {
    extraConfig = ''
      Host github.com
        IdentityFile ${config.sops.secrets.github_general_ssh_key.path}
    '';
  };

  # -----------------------------------------------------------------------
  # 🍎 MAC APP STORE APPS (Host Specific)
  # -----------------------------------------------------------------------
  # The app can only be installed if they are purchased/downloaded once manually from the app store
  homebrew.masApps = {
    "Whatsapp" = 310633997;
    "Microsoft Word" = 462054704;
    "Microsoft PowerPoint" = 462062816;
    "Microsoft Excel" = 462058435;
    "HP Print" = 1474276998;
    "DaVinci Resolve" = 571213070;
    "Keynote" = 409183694;
    "Numbers" = 409203825;
    "Pages" = 409201541;
    "Kindle" = 302584613;
    "geogebra" = 1182481622;
  };

  # -----------------------------------------------------------------------
  # ⚙️ SYSTEM DEFAULTS (Host Specific Overrides)
  # -----------------------------------------------------------------------
  system.defaults = {
    dock = {
      autohide = true; # Automatically hide and show the Dock
      launchanim = true; # Enable launch animation
      static-only =
        false; # If 'true', only shows active apps. If 'false', shows pinned apps too.
      show-recents = false; # Disable recent apps section
      show-process-indicators = true; # Show dot under running apps
      orientation = "bottom"; # Dock position: bottom, left, right
      tilesize = 50; # Icon size in pixels
      minimize-to-application =
        true; # Minimize windows into their application's icon
      mineffect = "scale";
      # Persistent Apps (Your common dock file logic goes here)
      persistent-apps = [
        "/Applications/Comet.app"
        "/Applications/Firefox.app"
        "/Applications/WhatsApp.app"
        "/Applications/kitty.app"
        "/System/Applications/Music.app"
        "/Applications/UGREEN NAS.app"
        "/Applications/Proton Pass.app"
        "/Applications/Discord.app"
        "/Applications/Nix Apps/Visual Studio Code.app"
        "/Applications/GitHub Desktop.app"
        "/System/Applications/Calendar.app"
      ];
    };

    # -----------------------------------------------------------------------
    # 📂 FINDER SETTINGS
    # -----------------------------------------------------------------------
    finder = {
      ShowExternalHardDrivesOnDesktop = true; # Show external drives on desktop
      ShowHardDrivesOnDesktop = false; # Show the main "Macintosh HD" icon
      ShowMountedServersOnDesktop = true; # Show network shares on desktop
      ShowRemovableMediaOnDesktop =
        true; # Show USB drives, cameras, etc. on desktop
      _FXSortFoldersFirst =
        true; # Keeps folders at the top when sorting by name
      FXDefaultSearchScope =
        "SCcf"; # "SCcf" = Search Current Folder.      NewWindowTarget = "PfDe"; # Desktop
      AppleShowAllExtensions = true; # Show all file extensions
      FXEnableExtensionChangeWarning =
        true; # Disable warning when changing file extensions
      ShowStatusBar = true; # Show status bar at bottom of Finder windows
      ShowPathbar = true; # Show path bar at bottom of Finder windows

      # Preferred view style in Finder windows
      # "icnv" = Icon View
      # "Nlsv" = List View
      # "clmv" = Column View
      # "flwv" = Gallery View
      FXPreferredViewStyle = "Nlsv";
    };

    # -----------------------------------------------------------------------
    # 🌐 GLOBAL MACOS SETTINGS
    # -----------------------------------------------------------------------
    NSGlobalDomain = {
      AppleShowScrollBars = "Always"; # Toggle show scroll bars
      NSUseAnimatedFocusRing =
        false; # Disables the animation when focusing text fields.
      NSNavPanelExpandedStateForSaveMode =
        true; # Expands the "Save As" dialog by default (showing full file browser).
      NSNavPanelExpandedStateForSaveMode2 =
        true; # Same as above, for different apps.
      PMPrintingExpandedStateForPrint =
        true; # Expands the print dialog to show all options by default.
      PMPrintingExpandedStateForPrint2 =
        true; # Expands the print dialog to show all options by default.
      NSDocumentSaveNewDocumentsToCloud =
        false; # Default save location is local disk, not iCloud
      ApplePressAndHoldEnabled =
        false; # Toggle the "Press and Hold" for accents character picker.
      InitialKeyRepeat = 25; # Delay until key repeat starts
      KeyRepeat = 2; # Key repeat rate
      "com.apple.mouse.tapBehavior" =
        1; # Enable tap to click for trackpad 1 = enabled, 0 = disabled
      NSWindowShouldDragOnGesture =
        true; # Allows dragging windows by clicking anywhere inside them while holding Ctrl+Cmd (Linux style).
      NSAutomaticSpellingCorrectionEnabled =
        false; # Toggle automatic spelling correction
    };

    # 🔧 CUSTOM USER PREFERENCES (For things not directly exposed by Nix options)
    CustomUserPreferences = {
      "com.apple.finder" = { WarnOnEmptyTrash = true; };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores =
          true; # Stops macOS from writing .DS_Store files on network drives
        DSDontWriteUSBStores =
          true; # Stops macOS from writing .DS_Store files on USB drives.
      };
      "com.apple.dock" = {
        enable-window-tool =
          false; # Disables a specific internal debug/window tool

      };
      "com.apple.ActivityMonitor" = {
        OpenMainWindow =
          true; # Ensures the main window opens when you launch the app.
        IconType =
          5; # Sets the dock icon to show a live CPU usage graph (5 = CPU Usage).
        SortColumn = "CPUUsage"; # Sorts processes by CPU usage by default.
        SortDirection = 0; # Sorts 0 = descending, 1 = ascending
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising =
          false; # Toggle targeted ads in Apple News/App Store.
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true; # Checks for updates automatically.
        ScheduleFrequency = 1; # How many days between checks (1 = daily).
        AutomaticDownload =
          1; # Automatically download updates in the background. 1 = true , 0 = false.
        CriticalUpdateInstall =
          1; # Automatically install critical updates. 1 = true , 0 = false.
      };
    };
  };
}
