{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, fetchzip
, gcc-unwrapped
, makeWrapper
, ocamlPackages
, model ? "small"
}:

let
  # https://alphacephei.com/vosk/models
  models = {
    big = fetchzip {
      url = "https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip";
      hash = "sha256-kakOhA7hEtDM6WY3oAnb8xKZil9WTA3xePpLIxr2+yM=";
    };
    small = fetchzip {
      url = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip";
      hash = "sha256-CIoPZ/krX+UW2w7c84W3oc1n4zc9BBS/fc8rVYUthuY=";
    };
  };

  installBin = bin: ''
    install -D $MP4GREP_INSTALL_PREFIX/${bin} $out/share/mp4grep/${bin}
    makeWrapper $out/share/mp4grep/${bin} $out/bin/${bin} \
    --run 'export MP4GREP_CACHE="$HOME/.cache/mp4grep"' \
    --run 'mkdir -p "$MP4GREP_CACHE"' \
    --set MP4GREP_MODEL ${models.${model}}
  '';

in
stdenv.mkDerivation rec
{
  pname = "mp4grep";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "o-oconnell";
    repo = "mp4grep";
    rev = "${version}-linux-x86";
    sha256 = "HsZZ+KDf4bpdvJjM42vh5u1gKhGSH+g6zYS0pRM5aTU=";
  };

  buildInputs = [
    gcc-unwrapped.lib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    ocamlPackages.ocaml
  ];

  dontStrip = true;
  OPAM_SWITCH_PREFIX = ".";
  MP4GREP_INSTALL_PREFIX = "./bin-nix";

  preBuild = ''
    mkdir $MP4GREP_INSTALL_PREFIX
    ln -s ${ocamlPackages.parmap}/lib/ocaml/4.14.0/site-lib/parmap $OPAM_SWITCH_PREFIX/lib/
  '';

  installPhase = ''
    install -D $MP4GREP_INSTALL_PREFIX/mp4grep-libs/libvosk.so $out/share/mp4grep/libvosk.so
    ${installBin "mp4grep"}
    ${installBin "mp4grep-convert"}
  '';
}
