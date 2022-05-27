pkgs:
let
  pkg = path: args:
    let
      p = pkgs.callPackage path args;
    in
    if p.meta.available then p else pkgs.emptyDirectory;
in
rec
{
  bck-nerdfont = pkg ./bck-nerdfont.nix { };
  binaryninja = pkg ./binary-ninja-personal { };
  commander-x16 = pkg ./commander-x16 { };
  mp4grep = pkg ./mp4grep.nix { };
  msfpc = pkg ./msfpc { };
  security-toolbox = pkg ./security-toolbox { inherit msfpc webshells weevely security-wordlists; };
  security-wordlists = pkg ./wordlists.nix { };
  SpaceCadetPinball = pkg ./SpaceCadetPinball { };
  stretchy-spaces = pkg ./stretchy-spaces { };
  vscode-vlang = pkg ./vscode-vlang { };
  webshells = pkg ./webshells { };
  weevely = pkg ./weevely { };
}
