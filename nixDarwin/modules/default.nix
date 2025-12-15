{ pkgs, ... }:
{
  imports = [
    ./configuration.nix
    ./nix.nix
    ./stylix.nix
  ];
}
