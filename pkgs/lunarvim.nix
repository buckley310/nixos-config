#
# https://github.com/NixOS/nixpkgs/pull/257063
#

{ pkgs }:
(
  (
    pkgs.callPackage
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/266e0f99a483d8e699f32b050c55981fd950de70/pkgs/by-name/lu/lunarvim/package.nix";
        sha256 = "fa44f06a517c686d181f35ee255d4e0c00c6f52473cf1a3b9586c4e511efb7d7";
      })
      { }

  ).overrideAttrs (_: {
    patches = [
      (
        pkgs.fetchurl {
          url = "https://github.com/LunarVim/LunarVim/commit/d187cbd03fbc8bd1b59250869e0e325518bf8798.patch";
          sha256 = "00677d3d5a4882d7ee5709e0494a5d8f7c58cea8bdcf467ce59222f9cc493366";
        }
      )
    ];
  })

).override (_: {
  python3.withPackages = _: pkgs.emptyDirectory;
})
