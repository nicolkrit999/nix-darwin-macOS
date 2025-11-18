# Introduzione, add if you need other components
{ pkgs, lib, ... }:

{
  home.username = "krit"; # Need to match the current user name
  home.homeDirectory = "/Users/krit"; # Need to match the current user directory path, the same as ~
  home.stateVersion = "24.05"; # Nix general version

  programs.home-manager.enable = true; # Enable home manager module

  # Define home environment variables for the current user
  home.sessionVariables = {
  JAVA_HOME = "${pkgs.jdk25}";
  JDTLS_BIN = "${pkgs.jdt-language-server}/bin/jdtls";
  };


  # Define the fact that the zsh configuration is defined in nix. ~/.zshrc is an alias and not the actual file
  programs.zsh = {
    enable = true; # Needed to allow nix to manage the zshrc
    enableCompletion = true; # Enable zsh completeation. It means when you press tab there is command/path/etc completetion (autosuggestion)
    autosuggestion.enable = true; # Enable autosuggestion (completetion) of command based on the history. You can accept the autosuggestion by pressing →
    syntaxHighlighting.enable = true; # Highlight command sintax allowing you to understand more clearly the different sections of the command

    # Replace all the conent of zshrc with the current one. This get loaded before the entire home manager. In the case this is not a wanted behaviour then initExtra is a better option
    # This block define homebrew path (mac specific), the iterm integration (mac specific), catpuccin mocha terminal theme, pokemon colorscripts when opening a new terminal
    initContent = ''
      export CASE_SENSITIVE="true"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" >/dev/null
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
          ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true
        fi
      fi
      if [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
        . "$HOME/.iterm2_shell_integration.zsh"
      fi
      export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
        --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8 \
        --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8 \
        --color=info:#94e2d5,prompt:#89b4fa,pointer:#f5c2e7 \
        --color=marker:#a6e3a1,spinner:#f5c2e7,header:#f9e2af,border:#45475a"
      case "$-" in
        *l*)
          if command -v pokemon-colorscripts >/dev/null 2>&1; then
            pokemon-colorscripts --no-title -r 1,3,6
          fi
          ;;
      esac
    '';
  };


  programs.command-not-found.enable = false; # Disable auto suggestion of nix to install a certain package/program if the runned command is not found

  # Define the zshr aliases
  home.shellAliases = {

    # Brew aliaes (not needed because nix define brew packages)
    #brew-upd        = "brew update && brew upgrade";
    #brew-upd-res     = "brew update-reset";
    #brew-inst       = "brew install";
    #brew-inst-cask   = "brew install --cask";
    #brew-search     = "brew search";
    #brew-clean  = "brew cleanup";

    # Ollama cli run (not needed because it's not installed)
    #ollama-advanced = "ollama run llama3:70b";
    #ollama-basic    = "ollama run llama3:8b";

    # Built in command improvement (require eza to be installed)
    sudo = "sudo ";
    l   = "eza -lh --icons=auto";
    ls  = "eza -1  --icons=auto";
    ll  = "eza -lha --icons=auto --sort=name --group-directories-first";
    ld  = "eza -lhD --icons=auto";
    lt  = "eza --icons=auto --tree";
    c   = "clear";
    h   = "history";
    which = "type -a";
    grep  = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";
    untar = "tar -xvzf";
    zshrc = "source ~/.zshrc";
    reb   = "sudo reboot";
    shut  = "sudo shutdown -h now";
    del   = "sudo rm -r";
    cp    = "cp -i";
    mkdir = "mkdir -p";
    aliasdelete = "find . -type l -print -delete";
    ".1" = "cd ..";
    ".2" = "cd ../..";
    ".3" = "cd ../../..";
    ".4" = "cd ../../../..";
    ".5" = "cd ../../../../..";
    ".6" = "cd ../../../../../..";

    # Caffeinate (mac specific)
    caff  = "caffeinate";

    # Nas wake on lan setup
    wakenas-local = "wakeonlan 6c:1f:f7:40:1e:d6";
    #wakenas-remotely = "wakeonlan -i 46.127.88.190 -p 9 6c:1f:f7:40:1e:d6";

    # Useful directory navigation
    downloads = "cd ~/Downloads";
    config    = "cd ~/.config";
    share     = "cd ~/.local/share/";
    opt       = "cd /opt/";

    # Useful git aliases
    clone        = "git clone";
    clonedepth1  = "git clone --depth=1";
    gitkeep      = "find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \\;";
    gac = "find /Users/krit/0001_Github_Repos -name '.git' -type d | while read gitdir; do repo=$(dirname \"$gitdir\"); echo \"Processing: $repo\"; (cd \"$repo\" && git add . && git commit -m \"General-$(date +%Y-%m-%d)\" && git push) 2>/dev/null || echo \"Failed: $repo\"; done";


    # Other commands
    youtube   = "yt-dlp -f bestvideo+bestaudio";
    btop      = "sudo btop";


    # Accept xcode license
    xcodeaccept = "sudo xcodebuild -license accept";

    # Various ssh access
    sshtailscale = "ssh krit@nicol-nas";
    sshnasip     = "ssh krit@192.168.1.98";
    sshos        = "ssh -l kritpio.nicol@supsi.ch linux1-didattica.supsi.ch";
    nas-ssh    = "cloudflared access ssh --hostname ssh.nicolkrit.ch";

    # Find available docker subnet
    dockersubnetcheck  = "sudo docker network ls --format 'table {{.Name}}\\t{{.Driver}}' && echo '' && sudo docker network ls --format '{{.Name}}' | xargs -I {} sudo docker network inspect {} --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}} {{end}}' 2>/dev/null || echo 'Error inspecting networks'";

    # Various dns utilities
    changehosts = "sudo nvim /etc/hosts";
    cleardns    = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";

    # Nix specific aliases
    nixpush = "cd /etc/nix-darwin/ && sudo nix run nix-darwin -- switch --flake .#Krits-MacBook-Pro";

    # Other directories navigation
    javanvim = "cd /Users/krit/developing-projects/java-projects/ && nvim";
    pythonnvim = "cd /Users/krit/developing-projects/python-projects/ && nvim";
    developingnvim = "cd /Users/krit/developing-projects && nvim";

    # Maven rebuild for java projects
    rebuildmvn = "cd ~/java-projects && mvn clean install";
  };
}
