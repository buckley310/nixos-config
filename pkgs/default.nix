pkgs:
let
  empty = pkgs.runCommand "empty" { } "mkdir $out";
  pkg = path: args:
    let
      p = pkgs.callPackage path args;
    in
    if p.meta.available then p else empty;
in
rec
{
  bck-nerdfont = pkg ./bck-nerdfont.nix { };
  binaryninja = pkg ./binary-ninja-personal { };
  commander-x16 = pkg ./commander-x16 { };
  gef = pkg ./gef { };
  mp4grep = pkg ./mp4grep.nix { };
  msfpc = pkg ./msfpc { };
  security-toolbox = pkg ./security-toolbox { inherit gef msfpc webshells weevely security-wordlists; };
  security-wordlists = pkg ./wordlists.nix { };
  SpaceCadetPinball = pkg ./SpaceCadetPinball { };
  stretchy-spaces = pkg ./stretchy-spaces { };
  webshells = pkg ./webshells { };
  weevely = pkg ./weevely { };
}
