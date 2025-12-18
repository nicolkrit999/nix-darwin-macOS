# Things to fix
These are the issues that i observed that require attentions. They may be only on my machine but they also may be a general problem

- [Things to fix](#things-to-fix)
  - [General](#general)
    - [You have set either `nixpkgs.config` or `nixpkgs.overlays` while using `home-manager.useGlobalPkgs`.](#you-have-set-either-nixpkgsconfig-or-nixpkgsoverlays-while-using-home-manageruseglobalpkgs)
  - [Home-manager modules](#home-manager-modules)
    - [Cava](#cava)

## General
### You have set either `nixpkgs.config` or `nixpkgs.overlays` while using `home-manager.useGlobalPkgs`.
- I tried my best but did not come up with a proper solution


## Home-manager modules
### Cava
- The current nixpkgs cava is broken, so for now the file is present but it is not imported
- Idea: wait for it to be fixed