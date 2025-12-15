{
  pkgs,
  lib,
  inputs,
  user,
  catppuccin,
  catppuccinFlavor,
  catppuccinAccent,
  ...
}:
{

  # TODO: Customize more (extensions)

  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (official module)
  # -----------------------------------------------------------------------
  catppuccin.firefox.enable = catppuccin;
  catppuccin.firefox.flavor = catppuccinFlavor;
  catppuccin.firefox.accent = catppuccinAccent;
  # Since it is a gtk theme, no firefox.enable = false; is needed in stylix.nix
  # -----------------------------------------------------------------------

  # 🔑 Password Manager Integration
  # Connects Firefox to 'browserpass' for secure credential handling.
  # Currently disabled due to proton pass usage
  programs.browserpass.enable = false;

  programs.firefox = {
    enable = true;
    profiles.${user} = {
      # 🔍 Search Configuration
      # Forces Google as default while keeping privacy options like Kagi and duck duck go available.
      search = {
        force = true; # Enforce custom search engine settings
        default = "google"; # Set Google as the default search engine
        privateDefault = "kagi"; # Set Kagi as the default for private browsing
        order = [
          "google"
          "kagi"
          "ddg"
        ]; # Preferred search engine order
        engines = {
          kagi = {
            name = "Kagi";
            urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ]; # Search URL template query parameter
            icon = "https://kagi.com/favicon.ico";
          };
          bing.metaData.hidden = true; # Hide unwanted search providers
        };
      };

      # 📑 Bookmarks
      bookmarks = { };

      # 🧩 Extensions
      # Declares essential plugins fetched from the nix flake inputs.
      extensions = {
        force = true; # Forced to allow catppuccin to modify the firefox color scheme
        packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          ublock-origin # Popular ad and tracker blocker
          proton-pass # Proton Pass password manager integration
          firefox-color # Custom Firefox themes and color schemes. Needed for catppuccin
        ];
      };

      # ⚙️ internal Firefox Settings (about:config)
      settings = {
        "browser.startup.homepage" = "https://glance.nicolkrit.ch";
        "browser.startup.page" = 1;

        # Disable irritating first-run stuff
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.feeds.showFirstRunUI" = false;
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.rights.3.shown" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.uitour.enabled" = false;
        "startup.homepage_override_url" = "";
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.bookmarks.addedImportButton" = true;

        # Don't ask for download dir
        "browser.download.useDownloadDir" = false;

        # Disable crappy home activity stream page
        # hides the default promoted/suggested tiles on Firefox's new-tab screen from several major websites.
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "browser.newtabpage.blocked" = lib.genAttrs [
          # Youtube
          "26UbzFJ7qT9/4DhodHKA1Q=="
          # Facebook
          "4gPpjkxgZzXPVtuEoAL9Ig=="
          # Wikipedia
          "eV8/WsSLxHadrTL1gAxhug=="
          # Reddit
          "gLv0ja2RYVgxKdp0I5qwvA=="
          # Amazon
          "K00ILysCaEq8+bEqV/3nuw=="
          # Twitter
          "T9nJot5PurhJSy8n038xGA=="
        ] (_: 1);

        # Disable some telemetry
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.sessions.current.clean" = true;
        "devtools.onboarding.telemetry.logged" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.prompted" = 2;
        "toolkit.telemetry.rejected" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.unifiedIsOptIn" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        # Disable fx accounts
        "identity.fxaccounts.enabled" = false;
        # Disable "save password" prompt
        "signon.rememberSignons" = false;
        # Harden
        "privacy.trackingprotection.enabled" = true;
        "dom.security.https_only_mode" = true;
        # Remove close button
        "browser.tabs.inTitlebar" = 0;
        # Vertical tabs
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.main.tools" = [
          "history"
          "bookmarks"
        ];
        # Toolbar placement: assigns buttons to specific navigation bar slots.
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            unified-extensions-area = [ ];
            widget-overflow-fixed-list = [ ];
            nav-bar = [
              "back-button"
              "forward-button"
              "vertical-spacer"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              "ublock0_raymondhill_net-browser-action"
              "_testpilot-containers-browser-action"
              "reset-pbm-toolbar-button"
              "unified-extensions-button"
            ];
            toolbar-menubar = [ "menubar-items" ];
            TabsToolbar = [ ];
            vertical-tabs = [ "tabbrowser-tabs" ];
            PersonalToolbar = [ "personal-bookmarks" ];
          };
          seen = [
            "save-to-pocket-button"
            "developer-button"
            "ublock0_raymondhill_net-browser-action"
            "_testpilot-containers-browser-action"
            "screenshot-button"
          ];
          dirtyAreaCache = [
            "nav-bar"
            "PersonalToolbar"
            "toolbar-menubar"
            "TabsToolbar"
            "widget-overflow-fixed-list"
            "vertical-tabs"
          ];
          currentVersion = 23;
          newElementCount = 10;
        };
      };
    };
  };

  # 🖥️ Default Mime Handlers
  # Sets Firefox as the system default for web protocols and HTML files.
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
