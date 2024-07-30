{ callPackage }:

callPackage ./bck-nvim-base {
  extraBinPaths = [
    (callPackage ./bck-nvim-tools.nix { })
  ];
}
