{ lib, vars, ... }:
let
  genPath = ./general-hm-modules;
  hostPath = ./host-hm-modules;
  genExists = builtins.pathExists genPath;
  hostExists = builtins.pathExists hostPath;
in
builtins.trace
  ">>> DEBUG: General Exists: ${toString genExists} | Host Exists: ${toString hostExists}"
  {
    imports = [
      ./dev-environments
      ./host-packages
      ./various
    ];

    home-manager.users.${vars.user} = {
      imports = [ ] ++ lib.optional genExists genPath ++ lib.optional hostExists hostPath;
    };
  }
