{ stdenv
, autoPatchelfHook
, libglvnd
, makeWrapper
, python3
, qt6
, requireFile
, unzip
}:

let
  hjs = builtins.fromJSON (builtins.readFile ./hashes.json);

in
stdenv.mkDerivation {
  pname = "binaryninja";
  inherit (hjs) version;

  src = requireFile rec {
    name = "binaryninja_personal_linux.zip";
    url = "https://binary.ninja";
    sha256 = hjs.hashes.${name};
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = [
    libglvnd
    qt6.full
  ];

  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp -a . $out/lib/binaryninja-personal
    uppath="~/.binaryninja/update/`echo -n $out/lib/binaryninja-personal|sha256sum|cut -c-64`"
    makeWrapper $out/lib/binaryninja-personal/binaryninja $out/bin/binaryninja \
        --run "install -D ${builtins.toFile "noauto" "{\"auto\":false}"} $uppath/manifest" \
        --suffix LD_LIBRARY_PATH : "${python3}/lib"
  '';

  meta.platforms = [ "x86_64-linux" ];
}
