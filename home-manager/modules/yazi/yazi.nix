{
  pkgs,
  lib,
  term,
  ...
}:
{
  imports = [
    ./init-lua.nix
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # 🛠️ WRAP YAZI TO FIX PATH ISSUES (Error 127)
    # This forces Yazi to see 'trash-cli' without manual Lua edits.
    package = pkgs.symlinkJoin {
      name = "yazi";
      paths = [ pkgs.yazi ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/yazi \
          --prefix PATH : "${
            lib.makeBinPath [
              pkgs.trash-cli
              pkgs.exiftool
            ]
          }"
      '';
    };

    # -----------------------------------------------------------------------
    # ⚙️ SETTINGS
    # -----------------------------------------------------------------------
    settings = {
      mgr = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "custom_metadata";
        show_hidden = false;
        show_symlink = true;
        scrolloff = 20;
        mouse_events = [
          "click"
          "scroll"
          "drag"
        ];
        title_format = "Yazi: {cwd}";
      };

      preview = {
        wrap = "no";
        tab_size = 2;
        max_width = 1920;
        max_height = 1080;
        cache_dir = ""; # Use default macOS cache
        image_delay = 5;
        image_filter = "lanczos3";
        image_quality = 90;
        image_preview_method =
          if
            builtins.elem term [
              "kitty"
              "ghostty"
              "wezterm"
              "iterm2"
            ]
          then
            "kitty"
          else if
            builtins.elem term [
              "foot"
              "blackbox"
            ]
          then
            "sixel"
          else
            "ueberzug";
        ueberzug_scale = 0.66;
        ueberzug_offset = [
          0
          0
          0
          0
        ];
      };

      opener = {
        edit = [
          {
            run = ''$EDITOR "$@"'';
            desc = "Edit";
            block = true;
          }
        ];
        play = [
          {
            run = ''open "$@"'';
            desc = "Play";
          }
        ];
        open = [
          {
            run = ''open "$@"'';
            desc = "Open";
          }
        ];
        reveal = [
          {
            run = ''open -R "''$1"'';
            desc = "Reveal";
          }
          {
            run = ''clear; exiftool "''$1"; echo "Press enter to exit"; read _'';
            desc = "Show EXIF";
            block = true;
          }
        ];
        extract = [
          {
            run = ''ouch d -y "$@"'';
            desc = "Extract here";
          }
        ];
        download = [
          {
            run = ''ya emit download --open "$@"'';
            desc = "Download and open";
          }
          {
            run = ''ya emit download "$@"'';
            desc = "Download";
          }
        ];
      };

      open = {
        rules = [
          {
            name = "*/";
            use = [
              "open"
              "reveal"
            ];
          }
          {
            mime = "text/*";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "image/*";
            use = [
              "open"
              "reveal"
            ];
          }
          {
            mime = "{audio,video}/*";
            use = [
              "play"
              "reveal"
            ];
          }
          {
            mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
            use = [
              "extract"
              "reveal"
            ];
          }
          {
            mime = "application/{json,ndjson}";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "*/javascript";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "inode/empty";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "vfs/{absent,stale}";
            use = "download";
          }
          {
            name = "*";
            use = [
              "open"
              "reveal"
            ];
          }
        ];
      };

      tasks = {
        micro_workers = 20;
        macro_workers = 20;
        bizarre_retry = 3;
        image_alloc = 1073741824;
        image_bound = [
          20000
          20000
        ];
        suppress_preload = false;
      };

      plugin = {
        fetchers = [
          {
            id = "mime";
            name = "*/";
            run = "mime";
            "if" = "!mime";
            prio = "high";
          }
          {
            id = "mime";
            name = "*";
            run = "mime";
            "if" = "!mime";
            prio = "high";
          }
        ];
      };
    };
  };

  # 📦 INSTALL PLUGINS (Nix Way)
  xdg.configFile."yazi/plugins/ouch".source = pkgs.fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "v0.7.0";
    sha256 = "03fjnga97bvrblvf53w7lp0k9ikkd81pa49qc0np7fg3fc8nlhyn";
  };

  xdg.configFile."yazi/plugins/recycle-bin".source = pkgs.fetchFromGitHub {
    owner = "uhs-robert";
    repo = "recycle-bin.yazi";
    rev = "main";
    sha256 = "00yh6w3f088dvhcb2464l86wxq7202bzgxjdnwi0i9cc1apgc54z";
  };

  # 🛠️ CREATE TRASH FOLDERS
  home.activation.createXdgTrash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.local/share/Trash/files
    mkdir -p ~/.local/share/Trash/info
  '';

  home.packages = with pkgs; [
    fzf
    zoxide
    ripgrep
    fd
    ffmpeg
    poppler
    jq
    zip
    unzip
    p7zip
    gnutar
    ueberzugpp
    chafa
    xdg-utils
    exiftool
    ouch
    trash-cli
  ];
}
