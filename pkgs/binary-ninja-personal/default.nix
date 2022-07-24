{ stdenv
, autoPatchelfHook
, makeWrapper
, ncurses
, qt6
, python3
, requireFile
, unzip
}:

let
  hjs = builtins.fromJSON (builtins.readFile ./hashes.js);

in
stdenv.mkDerivation {
  pname = "binaryninja";
  inherit (hjs) version;

  src = requireFile rec {
    name = "BinaryNinja-personal.zip";
    url = "https://binary.ninja";
    sha256 = hjs.hashes.${name};
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    qt6.wrapQtAppsHook
    unzip
  ];

  buildInputs = [
    ncurses
  ];

  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp -a . $out/lib/binaryninja-personal
    makeWrapper $out/lib/binaryninja-personal/binaryninja $out/bin/binaryninja \
        --suffix LD_LIBRARY_PATH : "${python3}/lib"
  '';

  meta.platforms = [ "x86_64-linux" ];
}
