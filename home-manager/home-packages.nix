{
  pkgs,
  pkgs-unstable,
  vars,
  ...
}:
let
  # 🔄 TRANSLATION LAYER
  translatedEditor = if vars.editor == "nvim" then "neovim" else vars.editor;

  # 🛡️ SAFE FALLBACKS for browser, fileManager, editor
  # If the user's choice is invalid or missing, these are installed.
  fallbackTerm = pkgs.alacritty;
  #fallbackBrowser = pkgs.google-chrome;
  fallbackFileManager = pkgs.yazi;
  fallbackEditor = pkgs.vscode;

  # 🔍 PACKAGE LOOKUP FUNCTION
  # Tries to find 'pkgs.userInput'. If not found, returns the fallback.
  getPkg = name: fallback: if builtins.hasAttr name pkgs then pkgs.${name} else fallback;

  myTermPkg = getPkg vars.term fallbackTerm;
  #myBrowserPkg = getPkg vars.browser fallbackBrowser;
  myFileManagerPkg = getPkg vars.fileManager fallbackFileManager;
  myEditorPkg = getPkg translatedEditor fallbackEditor;
in
{
  home.packages =
    # 1. DYNAMIC INSTALLATION
    # These are installed based on user choices in variables.nix: browser, fileManager, editor
    [
      myTermPkg
      #myBrowserPkg
      myFileManagerPkg
      myEditorPkg
    ]
    ++ (with pkgs; [
      # 🖥️ DESKTOP APPLICATIONS
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------------------
      # 🖥️ CLI UTILITIES
      # -----------------------------------------------------------------------------------

      # -----------------------------------------------------------------------
      # 🪟 WINDOW MANAGER (WM) INFRASTRUCTURE
      # -----------------------------------------------------------------------

      # -----------------------------------------------------------------------
      # ❓ OTHER
      # -----------------------------------------------------------------------
    ])
    # 4. UNSTABLE PACKAGES
    ++ (with pkgs-unstable; [

    ]);
}
