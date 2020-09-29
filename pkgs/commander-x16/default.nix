{ callPackage, symlinkJoin }:

symlinkJoin {
  name = "commander-x16-tools";
  paths = [
    (callPackage ./cc65.nix { })
    (callPackage ./emulator.nix { })
  ];
}
