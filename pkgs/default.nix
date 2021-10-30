self:
pkgs:

let

  allArchs =
    {
      commander-x16 = pkgs.callPackage ./commander-x16 { };
      gef = pkgs.callPackage ./gef { };
      stretchy-spaces = pkgs.callPackage ./stretchy-spaces { };
      webshells = pkgs.callPackage ./webshells { };
      weevely = pkgs.callPackage ./weevely { };
    };

  x64Lin =
    {
      binaryninja = pkgs.callPackage ./binary-ninja-personal { };
      packettracer = pkgs.callPackage ./packettracer { };
      SpaceCadetPinball = pkgs.callPackage ./SpaceCadetPinball { };
      security-toolbox = pkgs.callPackage ./security-toolbox {
        pkgs = pkgs // self.packages.${pkgs.system};
      };
    };

in
allArchs // (if pkgs.system != "x86_64-linux" then { } else x64Lin)
