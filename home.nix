{ pkgs, lib, ... }:

{
  home.username = "krit";
  home.homeDirectory = "/Users/krit";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
  JAVA_HOME = "${pkgs.jdk25}";
  JDTLS_BIN = "${pkgs.jdt-language-server}/bin/jdtls";
  };


  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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


  programs.command-not-found.enable = false;

  home.shellAliases = {
    upd        = "brew update && brew upgrade";
    updres     = "brew update-reset";
    inst       = "brew install";
    instcask   = "brew install --cask";
    search     = "brew search";
    brewcache  = "brew cleanup";
    ollamaadvanced = "ollama run llama3:70b";
    ollamabasic    = "ollama run llama3:8b";
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
    caff  = "caffeinate";
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
    wakenas-local = "wakeonlan 6c:1f:f7:40:1e:d6";
    wakenas-remotely = "wakeonlan -i 46.127.88.190 -p 9 6c:1f:f7:40:1e:d6";
    downloads = "cd ~/Downloads";
    config    = "cd ~/.config";
    share     = "cd /opt/homebrew/bin";
    opt       = "cd /opt/homebrew/opt";
    clone        = "git clone";
    clonedepth1  = "git clone --depth=1";
    gitkeep      = "find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \\;";
    gac = "find /Users/krit/0001_Github_Repos -name '.git' -type d | while read gitdir; do repo=$(dirname \"$gitdir\"); echo \"Processing: $repo\"; (cd \"$repo\" && git add . && git commit -m \"General-$(date +%Y-%m-%d)\" && git push) 2>/dev/null || echo \"Failed: $repo\"; done";
    setup     = "cd ~/0001_Github_Repos/0001_MacOS_Setup";
    personal  = "cd ~/0001_Github_Repos/0002_Personal_repos";
    work      = "cd ~/0001_Github_Repos/0003_Work";
    various   = "cd ~/0001_Github_Repos/0004_Various";
    youtube   = "yt-dlp -f bestvideo+bestaudio";
    htop      = "sudo htop";
    xcodeaccept = "sudo xcodebuild -license accept";
    sshtailscale = "ssh krit@nicol-nas";
    sshnasip     = "ssh krit@192.168.1.98";
    sshos        = "ssh -l kritpio.nicol@supsi.ch linux1-didattica.supsi.ch";
    nas-ssh    = "cloudflared access ssh --hostname ssh.nicolkrit.ch";
    nasdockerubuntucli = "sudo docker exec -it Ubuntu-Krit-admin-dc /bin/bash";
    dockersubnetcheck  = "sudo docker network ls --format 'table {{.Name}}\\t{{.Driver}}' && echo '' && sudo docker network ls --format '{{.Name}}' | xargs -I {} sudo docker network inspect {} --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}} {{end}}' 2>/dev/null || echo 'Error inspecting networks'";
    changehosts = "sudo nvim /etc/hosts";
    cleardns    = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
    nixpush = "cd /etc/nix-darwin/ && sudo nix run nix-darwin -- switch --flake .#Krits-MacBook-Pro";
    javanvim = "cd /Users/krit/developing-projects/java-projects/ && nvim";
    pythonnvim = "cd /Users/krit/developing-projects/python-projects/ && nvim";
    developingnvim = "cd /Users/krit/developing-projects && nvim";
    rebuildmvn = "cd ~/java-projects && mvn clean install";
  };
}
