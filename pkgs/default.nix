pkgs:
let
  empty = pkgs.runCommand "empty" { } "mkdir $out";
  x64 = x: if pkgs.system == "x86_64-linux" then x else empty;
in
rec
{
  binaryninja = x64 (pkgs.callPackage ./binary-ninja-personal { });
  commander-x16 = pkgs.callPackage ./commander-x16 { };
  gef = pkgs.callPackage ./gef { };
  packettracer = x64 (pkgs.callPackage ./packettracer { });
  security-toolbox = x64 (pkgs.callPackage ./security-toolbox { inherit gef webshells weevely; });
  SpaceCadetPinball = x64 (pkgs.callPackage ./SpaceCadetPinball { });
  stretchy-spaces = pkgs.callPackage ./stretchy-spaces { };
  webshells = pkgs.callPackage ./webshells { };
  weevely = pkgs.callPackage ./weevely { };
}
