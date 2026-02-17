{
  imports = [
    # Folder imports
    #./librewolf #TODO: Wait for the librewolf module to be released for nix-darwin

    # File imports
    ./chromium.nix
    ./firefox.nix
  ];
}
