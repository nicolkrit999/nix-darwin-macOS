{
  # 💻 HOST IDENTITY
  hostname = "Krits-MacBook-Pro";
  user = "krit";
  system = "aarch64-darwin";
  darwinStateVersion = 4; # Do not change unless it's a new pc. Keep it as integer
  homeStateVersion = "25.11"; # Do not change unless it's a new pc

  shell = "fish";

  term = "kitty";
  editor = "nvim";
  browser = "firefox";
  fileManager = "yazi";
  uid = 501;

  # 🎨 THEMING
  base16Theme = "rose-pine-moon";
  polarity = "dark";

  # Catppuccin Logic (Disable if using Nord)
  catppuccin = false;
  catppuccinFlavor = "macchiato"; # Unused if false
  catppuccinAccent = "mauve";

  # 🐙 GIT CONFIG
  gitUserName = "nicolkrit999";
  gitUserEmail = "githubgitlabmain.hu5b7@passfwd.com";

  devLanguages = [
    # Development environments configurations.
    # If a module is enabled their respective packages are installed permanently
    # To use them it's needed to add a .envrc file in the project folder that link to the dev-environment
    #"c-cpp"
    #"go"
    #"haskell"
    "java"
    #"jupyter"
    "latex"
    "nix"
    #"node"
    #"php"
    "python"
    #"r"
    #"rust"
    "shell"
    #"swift"
    "typst"
  ];
}
