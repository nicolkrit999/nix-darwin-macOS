{ pkgs, ... }:
{
  # ---------------------------------------------------
  # 1. SYSTEM SETTINGS & DEFAULTS
  # ---------------------------------------------------
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # Enable Touch ID for sudo (Saved you from typing passwords!)
  security.pam.services.sudo_local.touchIdAuth = true;

  # Build users group ID (from your old config)
  ids.gids.nixbld = 350;

  nix.enable = false;

  # ---------------------------------------------------
  # 2. SYSTEM PACKAGES (Restored your Full List)
  # ---------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Core & Shell
    starship
    eza
    btop
    ripgrep
    fd
    fzf
    bat
    unzip
    which
    tree
    stow
    ranger
    tealdeer
    xclip
    wakeonlan
    zlib
    nh

    # Dev Tools
    git
    lazygit
    cmake
    docker
    universal-ctags
    jq
    glow
    grex

    # Editors
    neovim
    # Note: Vim plugins are usually better managed in home-manager/neovim.nix,
    # but we keep them here if you prefer system-wide availability.

    # Languages & Runtimes
    jdk25
    maven
    gradle
    jdt-language-server
    nodejs
    glew
    glfw # C/C++ libs
    rbenv
    postgresql_14
    redis

    # Python Bundle (Restored your specific list)
    (python313.withPackages (
      ps: with ps; [
        pip
        setuptools
        pynvim
        python-lsp-server
        python-lsp-black
        pylsp-mypy
        isort
        pylint
        flake8
        black
        ruff
        faker
      ]
    ))

    # Documents & Media
    pandoc
    tectonic
    texliveFull # Warning: Huge download!
    mermaid-cli
    ghostscript
    imagemagick
    sox
    yt-dlp
    viu
    chafa
    ueberzugpp

    # Networking
    cloudflared
    speedtest-cli
    croc
    ttyd

    # Fun
    pay-respects
    fastfetch
    pokemon-colorscripts
    neo-cowsay
    cbonsai
    asciinema

    # Fonts support
    pkgs.inter
    pkgs.noto-fonts
    pkgs.nerd-fonts.jetbrains-mono

  ];

  # ---------------------------------------------------
  # 3. HOMEBREW CONFIGURATION
  # ---------------------------------------------------
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "uninstall"; # Restored your declarative cleanup
    };

    taps = [ ];

    brews = [
      "pipes-sh"
      "nixfmt"
    ];

    casks = [
      "firefox"
      "alacritty"
      "pearcleaner"
      "only-switch"
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
