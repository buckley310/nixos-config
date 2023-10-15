#
# https://github.com/NixOS/nixpkgs/pull/261103
#

{ pkgs }:
(
  pkgs.callPackage
    (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/99dadc5f534b7ba85582c8ee492599585069d20e/pkgs/by-name/lu/lunarvim/package.nix";
      sha256 = "211d9cf8d5d352d220785ba90c7800d588c34e6e1c4a3dcbf02013d1fa49977c";
    })
    { }

).override (_: {
  viAlias = true;
  vimAlias = true;
  globalConfig = builtins.readFile ../modules/vim/init.lua;
})
