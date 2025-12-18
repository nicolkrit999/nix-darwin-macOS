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
    fd # User-friendly replacement for 'find'
    ffmpeg # Multimedia framework for audio/video processing
    glow # Markdown renderer for the terminal
    grex # Command-line tool for generating regular expressions
    mediainfo # Display technical info about media files
    ntfs3g # NTFS read/write support
    tree # Display directory structure as a tree
    yt-dlp # Media downloader for YouTube and other sites
    fastfetch # Fast system information fetcher
    pokemon-colorscripts # Print pokemon sprites in terminal with colors
    lsof # List open files
    cloudflared # Cloudflare's command-line tool and daemon
    pay-respects # Shell commands suggestion
    # -----------------------------------------------------------------------------------
    # 🧑🏽‍💻 CODING
    # -----------------------------------------------------------------------------------
    cmake # Cross-platform build system
    docker # Containerization platform
    jq # Command-line JSON processor
    tectonic # Modernized, complete, self-contained TeX/LaTeX engine
    texliveFull # The complete TeX Live distribution (Note: Large download)
    universal-ctags # Tool to generate index (tags) files of source code
    maven # Java build tool
    jetbrains.pycharm-oss # Python IDE
    jetbrains.clion # C/C++ IDE
    jetbrains.idea-oss # Java IDE
    zeal # Offline documentation browser
    (pkgs.python313.withPackages (
      ps: with ps; [
        setuptools # Library for packaging Python projectsS
        isort # Sort imports alphabetically
        pylint # Source code analyzer
        pyright # Static type checker
        faker # Generate fake data
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
