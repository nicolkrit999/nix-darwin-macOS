{
  pkgs,
  lib,
  inputs,
  user, # 1. Passed from flake.nix (Dynamic User)
  catppuccin, # 2. Passed from flake.nix (Boolean)
  catppuccinFlavor, # 3. Passed from flake.nix (String)
  catppuccinAccent, # 4. Passed from flake.nix (String)
  ...
}:
{
  # -----------------------------------------------------------------------
  # 🎨 CATPPUCCIN THEME (Official Module)
  # -----------------------------------------------------------------------
  # This logic mirrors your NixOS config exactly.
  # If catppuccin is enabled in flake.nix, it applies here.
  catppuccin.firefox.enable = catppuccin;
  catppuccin.firefox.flavor = catppuccinFlavor;
  catppuccin.firefox.accent = catppuccinAccent;

  programs.browserpass.enable = false;

  programs.firefox = {
    enable = true;

    # 🧠 SMART PROFILE CREATION
    # Creates a profile named after the current user ("krit" or "roberta")
    profiles.${user} = {

      # 🔍 Search Configuration
      search = {
        force = true;
        default = "google";
        privateDefault = "kagi";
        order = [
          "google"
          "kagi"
          "duckduckgo"
        ];
        engines = {
          kagi = {
            name = "Kagi";
            urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
            icon = "https://kagi.com/favicon.ico";
          };
          bing.metaData.hidden = true;
        };
      };

      bookmarks = { };

      # 🧩 Extensions
      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          proton-pass
          firefox-color
        ];
      };

      # ⚙️ Internal Settings (about:config)
      settings = {
        "browser.startup.homepage" = "https://glance.nicolkrit.ch";
        "browser.startup.page" = 1;
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.main.tools" = [
          "history"
          "bookmarks"
        ];

        # UI Customization (Toolbar)
        "browser.uiCustomization.state" = builtins.toJSON {
          currentVersion = 20;
          newElementCount = 5;
          placements = {
            widget-overflow-fixed-list = [ ];
            nav-bar = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              "ublock0_raymondhill_net-browser-action"
              "_testpilot-containers-browser-action"
              "unified-extensions-button"
            ];
            toolbar-menubar = [ "menubar-items" ];
            TabsToolbar = [
              "tabbrowser-tabs"
              "new-tab-button"
              "alltabs-button"
            ];
            vertical-tabs = [ "tabbrowser-tabs" ];
            PersonalToolbar = [ "personal-bookmarks" ];
          };
        };
      };
    };
  };

  # 🖥️ DEFAULT HANDLERS (Linux Only)
  # ⚠️ We wrap this in a check because macOS handles defaults differently
  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "text/xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
