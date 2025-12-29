{ config, pkgs, ... }:

let
  nasUser = "krit";
  nasHost = "nicol-nas";
  nasBaseDir = "/volume1/Default-volume-1/0001_Docker/borgitory";
  nasRepoPath = "${nasBaseDir}/${config.networking.hostName}";

  # Local secrets
  secretPath = "/Users/krit/.config/borg-secrets";
  passphraseFile = "${secretPath}/passphrase";
  sshKeyPath = "${secretPath}/id_borg";

  excludes = [
    # ---------------------------------------------------------
    # 🔒 SECURITY (CRITICAL)
    # ---------------------------------------------------------
    "/Users/krit/.config/borg-secrets" # NEVER backup the backup keys!
    "/Users/krit/.ssh" # Exclude private keys

    # ---------------------------------------------------------
    # 🗑️ JUNK PATTERNS (Recursive)
    # ---------------------------------------------------------
    "**/.DS_Store" # Covers .DS_Store in ALL folders
    "**/.stfolder*" # Covers .stfolder AND .stfolder-xyz
    "**/.stignore"
    "**/.localized"

    # Electron/App Caches
    "*/Code Cache"
    "*/GPUCache"
    "*/DawnWebGPUCache"
    "*/DawnGraphiteCache"
    "*/Session Storage"
    "*/blob_storage"
    "*/PersistentCache"

    # Noisy file extensions
    "*.log"
    "*.tmp"
    "*.bak"
    "*.sock"
    "*.vdi"
    "*.qcow2"
    "*.iso"
    "*.vmwarevm"

    # ---------------------------------------------------------
    # 📂 HEAVY / SYNCED FOLDERS (Don't backup)
    # ---------------------------------------------------------
    "/Users/krit/Library" # Entire Library (iCloud/Caches)
    "/Users/krit/Applications"
    "/Users/krit/Downloads"
    "/Users/krit/Public"
    "/Users/krit/Music"
    "/Users/krit/Movies"
    "/Users/krit/Pictures/Photos Library.photoslibrary"
    "/Users/krit/Pictures/Photo Booth Library"
    "/Users/krit/Documents/Actual" # Synced on NAS

    # ---------------------------------------------------------
    # 💻 DEVELOPMENT & REPOS (Github/Nix managed)
    # ---------------------------------------------------------
    "/Users/krit/nixOS"
    "/Users/krit/nix-darwin-macOS"
    "/Users/krit/dotfiles"
    "/Users/krit/developing-projects"
    "/Users/krit/tools" # jdtls etc.
    "/Users/krit/.nix-defexpr"
    "/Users/krit/.nix-profile"
    "/Users/krit/.local" # Local state/share
    "/Users/krit/.cache"
    "/Users/krit/.npm"
    "/Users/krit/.m2"
    "/Users/krit/.gradle"
    "/Users/krit/.cargo"
    "/Users/krit/.vscode"
    "/Users/krit/.mozilla"

    # ---------------------------------------------------------
    # 📱 APP CONFIGS (Managed by Dotfiles/Nix)
    # ---------------------------------------------------------
    "/Users/krit/.config/raycast"
    "/Users/krit/.config/kitty"
    "/Users/krit/.config/git"
    "/Users/krit/.config/nvim"
    "/Users/krit/.config/tmux"
    "/Users/krit/.config/alacritty"
    "/Users/krit/.config/bat"
    "/Users/krit/.config/stylix"
    "/Users/krit/.config/ranger"
    "/Users/krit/.config/fastfetch"
    "/Users/krit/.config/iterm2"
    "/Users/krit/.config/forge"
    "/Users/krit/.config/gdu"
    "/Users/krit/.config/gtk-3.0"
    "/Users/krit/.config/gtk-4.0"
    "/Users/krit/.config/blender"
    "/Users/krit/.config/starship.toml"
    "/Users/krit/.config/Code"
    "/Users/krit/.config/Cursor"
    "/Users/krit/.config/Vencord"

    # ---------------------------------------------------------
    # ⚙️ SYSTEM FILES (Regeneratable)
    # ---------------------------------------------------------
    "/Users/krit/.Trash"
    "/Users/krit/.terminfo"
    "/Users/krit/.themes"
    "/Users/krit/.lazygit"
    "/Users/krit/.zcompdump"
    "/Users/krit/.zsh_sessions"
    "/Users/krit/.zsh_history"
    "/Users/krit/.histfile"
    "/Users/krit/.zshrc"
    "/Users/krit/.zshrc_custom"
    "/Users/krit/.zshenv"
    "/Users/krit/.Xresources"
    "/Users/krit/.gtkrc-2.0"
    "/Users/krit/.CFUserTextEncoding"
    "/Users/krit/com.visualstudio.code.tunnel.plist"
  ];
in
{
  environment.systemPackages = [ pkgs.borgmatic ];

  environment.etc."borgmatic/config.yaml".text = ''
    location:
      source_directories:
        - /Users/krit

      repositories:
        - path: ssh://${nasUser}@${nasHost}${nasRepoPath}
          label: nas-repo

      exclude_patterns:
        ${builtins.concatStringsSep "\n    " (map (x: "- \"${x}\"") excludes)}

    storage:
      compression: auto,zstd
      archive_name_format: '{hostname}-{now}'
      encryption_passcommand: cat ${passphraseFile}

    retention:
      keep_daily: 7
      keep_weekly: 4
      keep_monthly: 6

    consistency:
      checks:
        - repository
        - archives

    ssh_command: ssh -i ${sshKeyPath} -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30
  '';

  launchd.user.agents.borgmatic-backup = {
    serviceConfig = {
      Label = "com.borgmatic.backup";

      # 🏃‍♂️ RUN ON BOOT/LOGIN (Catches up if you were powered off)
      RunAtLoad = true;

      # 🐢 PERFORMANCE (Don't slow down the Mac)
      LowPriorityIO = true;
      Nice = 5;

      EnvironmentVariables = {
        BORG_PASSCOMMAND = "cat ${passphraseFile}";
      };

      ProgramArguments = [
        "${pkgs.borgmatic}/bin/borgmatic"
        "--syslog-verbosity"
        "1"
      ];

      StartCalendarInterval = [
        {
          Hour = 10;
          Minute = 0;
        }
        {
          Hour = 14;
          Minute = 0;
        }
        {
          Hour = 22;
          Minute = 0;
        }
      ];

      StandardOutPath = "/Users/krit/Library/Logs/borgmatic.log";
      StandardErrorPath = "/Users/krit/Library/Logs/borgmatic.err";
    };
  };

}
