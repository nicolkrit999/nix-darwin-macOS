{
  config,
  lib,
  vars,
  ...
}:

let
  # 📂 Define your Flake directory once for cleaner aliases
  flakeDir = "~/nix-darwin-macOS";
in

lib.mkIf ((vars.shell or "zsh") == "fish") {
  programs.fish = {
    enable = true;

    # -----------------------------------------------------------------------
    # ⌨️ ABBREVIATIONS
    # -----------------------------------------------------------------------
    shellAbbrs = {
      brew-upd = "brew update && brew upgrade";
      brew-upd-res = "brew update-reset";
      brew-inst = "brew install";
      brew-inst-cask = "brew install --cask";
      brew-search = "brew search";
      brew-clean = "brew cleanup";
      sw = "nh darwin switch ${flakeDir}";
      upd = "cd ${flakeDir} && nix flake update && darwin-rebuild switch --flake ${flakeDir}";

      hms = "home-manager switch --flake ${flakeDir}";

      pkgs = "nvim ${flakeDir}/home-manager/modules/default.nix";

      # 🧹 FORMATTING
      fmt = "cd ${flakeDir} && nix fmt -- **/*.nix"; # Format Nix files using nixfmt (a regular nix fmt hangs on zed theme)
      fmt-dry = "cd ${flakeDir} && nix fmt --check";

      # Utilities
      caff = "caffeinate";
      xcodeaccept = "sudo xcodebuild -license accept";
      changehosts = "sudo nvim /etc/hosts";
      cleardns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      fzf-prev = ''fzf --preview="cat {}"'';
      zlist = "zoxide query -l -s"; # List all zoxide entries with scores

      # Nix-Darwin Maintenance
      nixpush = "cd ~/nix-darwin-macOS/ && sudo darwin-rebuild switch --flake .#$(scutil --get LocalHostName)";
      cdnix = "cd ~/nix-darwin-macOS/";
      nfc = "cd ${flakeDir} && nix flake check"; # Check flake for errors
      swdry = "cd ${flakeDir} && nh os test --dry --ask"; # Dry run of nixos-rebuild switch

    };

    # -----------------------------------------------------
    # ⚙️ INITIALIZATION
    # -----------------------------------------------------
    interactiveShellInit = ''

      # 2. LOAD USER CONFIG
      if test -f "$HOME/.custom.fish"
        source "$HOME/.custom.fish"
      end

      # 3. TMUX AUTOSTART
      if status is-interactive
        and not set -q TMUX
        # 'exec' replaces the shell so exiting tmux closes the window
        exec tmux new-session -A -s main
      end

      # 4. Disable greeting
      set -U fish_greeting

      # 2. Fix fish-specific globbing and binding conflicts
      # Also solve tmux alt c conflict
      bind --erase --all alt-c 
      bind ctrl-g fzf-cd-widget
    '';

    # -----------------------------------------------------
    # 📝 FUNCTIONS
    # -----------------------------------------------------
    functions = {

      npu = ''
        set url ""
        if test -n "$argv[1]"
            set url "$argv[1]"
        else
            read -P "🔗 Enter URL: " url
        end

        if test -z "$url"
            echo "❌ No URL provided."
            return 1
        end

        # 1. Handle GitHub Blobs (Convert to Raw)
        if string match -q "https://github.com/*/blob/*" -- "$url"
            set url (string replace "github.com" "raw.githubusercontent.com" "$url" | string replace "/blob/" "/")
            echo "🔄 Converted Github Blob to Raw"
        end

        set args

        # 2. Handle GitHub Archives (Commits, Releases, Branches)
        if string match -q "https://github.com/*" -- "$url"
            if string match -q "*/commit/*" -- "$url"
                set url (string replace "/commit/" "/archive/" "$url").tar.gz
                set args --unpack
                echo "📦 Detected Github Commit -> Downloading Archive"
            else if string match -q "*/releases/tag/*" -- "$url"
                set url (string replace "/releases/tag/" "/archive/refs/tags/" "$url").tar.gz
                set args --unpack
                echo "📦 Detected Github Release -> Downloading Archive"
            else if string match -q "*/tree/*" -- "$url"
                set url (string replace "/tree/" "/archive/refs/heads/" "$url").tar.gz
                set args --unpack
                echo "📦 Detected Github Branch -> Downloading Archive"
            end
        end

        # 3. Handle Filename Decoding (Only if not unpacking)
        if test -z "$args"
            set filename (basename "$url")
            if command -q python3
                set decoded_name (python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))" "$filename")
                if test "$filename" != "$decoded_name"
                    set args --name "$decoded_name"
                    echo "✨ Decoded filename: '$decoded_name'"
                end
            end
        end

        # Execute
        nix-prefetch-url $args "$url"
      '';
    };
  };
}
