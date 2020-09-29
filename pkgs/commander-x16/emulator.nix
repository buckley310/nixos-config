{ stdenv, callPackage, fetchFromGitHub, SDL2 }:
let
  rev = "r38";
  owner = "commanderx16";
  cc65 = callPackage ./cc65.nix { };

  x16rom = stdenv.mkDerivation rec {
    name = "x16-rom";

    src = fetchFromGitHub {
      inherit owner rev;
      repo = name;
      sha256 = "10m6v0xpjkbrnjspsn7z0r22wphbvcrxw8f59z98xv21kb98ban5";
    };

    buildInputs = [ cc65 ];

    preBuild = ''
      patchShebangs scripts
    '';

    installPhase = ''
      cp ./build/x16/rom.bin "$out"
    '';
  };

in
stdenv.mkDerivation rec {
  name = "x16-emulator";

  src = fetchFromGitHub {
    inherit owner rev;
    repo = name;
    sha256 = "10cidc825bz3bniwascn472a9a8087f9lfl9b20r6dkvdzz6mm2q";
  };

  buildInputs = [ SDL2.dev ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp x16emu "$out/"
    ln -s "${x16rom}" "$out/rom.bin"
    ln -s "$out/x16emu" "$out/bin/x16emu"
  '';
}
