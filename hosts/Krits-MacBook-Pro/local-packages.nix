{ pkgs, user, ... }:
{
  # ------------------------------------------------------
  # 🖥️ HOST-SPECIFIC PACKAGES (Krits-MacBook-Pro)
  # ------------------------------------------------------
  users.users.${user}.packages = with pkgs; [
    # This allow guest user to not have this packages installed
    # Packages in each category are sorted alphabetically

    # -----------------------------------------------------------------------
    # 🖥️ DESKTOP APPLICATIONS
    # -----------------------------------------------------------------------

    # -----------------------------------------------------------------------------------
    # 🖥️ CLI UTILITIES
    # -----------------------------------------------------------------------------------
    bc # Arbitrary precision calculator
    carbon-now-cli # Create beautiful images of your code (carbon.now.sh CLI)
    cloudflared # Cloudflare's command-line tool and daemon
    fastfetch # Fast system information fetcher
    fd # User-friendly replacement for 'find'
    ffmpeg # Multimedia framework for audio/video processing
    gh # GitHub CLI tool
    glow # Markdown renderer for the terminal
    grex # Command-line tool for generating regular expressions
    lsof # List open files
    mediainfo # Display technical info about media files
    ntfs3g # NTFS read/write support
    pass # Simple password manager
    pay-respects # Shell commands suggestion
    pokemon-colorscripts # Print pokemon sprites in terminal with colors
    tree # Display directory structure as a tree
    yt-dlp # Media downloader for YouTube and other sites
    zoxide # Fast, lightweight alternative to 'cd'
    # -----------------------------------------------------------------------------------
    # 🧑🏽‍💻 CODING
    # -----------------------------------------------------------------------------------
    cmake # Cross-platform build system
    docker # Containerization platform
    jq # Command-line JSON processor
    maven # Java build tool
    tectonic # Modernized, complete, self-contained TeX/LaTeX engine
    texliveFull # The complete TeX Live distribution (Note: Large download)
    universal-ctags # Tool to generate index (tags) files of source code
    zeal # Offline documentation browser
    (pkgs.python313.withPackages (
      ps: with ps; [
        faker # Generate fake data
        isort # Sort imports alphabetically
        pyright # Static type checker
        pylint # Source code analyzer
        setuptools # Library for packaging Python projects
      ]
    ))

    # -----------------------------------------------------------------------------------
    # 😂 FUN PACKAGES
    # -----------------------------------------------------------------------------------

    asciinema # Record and share terminal sessions
    cbonsai # Grow bonsai trees in your terminal
    neo-cowsay # Cowsay reborn (ASCII art with text)

    # -----------------------------------------------------------------------
    # ❓ OTHER
    # -----------------------------------------------------------------------

  ];
}
