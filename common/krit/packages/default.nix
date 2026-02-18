{ pkgs, lib, ... }:
let
  # Check architecture
  isX86 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
  isARM = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
in
{
  home.packages =
    # ============================
    # 🐧 GLOBAL PACKAGES (Both)
    # ============================
    [
      # Packages that work everywhere
    ]

    # ============================
    # 💻 x86_64 ONLY
    # ============================
    ++ lib.optionals isX86 [
      #(pkgs.callPackage ./utilities/ { })

    ]

    # ============================
    # 🍎 ARM ONLY (Laptop)
    # ============================
    ++ lib.optionals isARM [
      # (pkgs.callPackage ./utilities/some-arm-app.nix { })
    ];
}
