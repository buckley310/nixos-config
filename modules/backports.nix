{ lib, ... }:
let
  rev = "00783f3f041491fc8b290da3494187b7f47100c0";

  backport = (name: path: sha256: self: super: {
    ${name} = super.callPackage
      (super.fetchurl {
        inherit sha256;
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/${rev}/pkgs/${path}";
      })
      { };
  });

in
{
  nixpkgs.overlays =
    [
      (backport "powerline-go" "tools/misc/powerline-go/default.nix" "3f5bceb483167dfea7bfb88bd3226c375be9564a8b321096bf1456c905acb90b")
    ];
}
