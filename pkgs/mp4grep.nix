{ lib
, stdenv
, fetchurl
, gcc-unwrapped
, jre
, makeWrapper
, unzip
}:

let

  pname = "mp4grep";
  version = "0.1.1";

  files = stdenv.mkDerivation
    {
      pname = "${pname}-files";
      inherit version;
      src = fetchurl {
        url = "https://github.com/o-oconnell/${pname}/releases/download/v${version}/${pname}-${version}.zip";
        sha256 = "3e63a9097ca8046eb22effee075aac71179a3c94d463049c42397a10f4087d8b";
      };
      nativeBuildInputs = [ makeWrapper unzip ];
      installPhase = ''
        cp -a . $out
        makeWrapper $out/bin/${pname} $out/launch \
        --set JAVA_HOME ${jre} \
        --run 'export MP4GREP_CACHE="$HOME/.cache/mp4grep"' \
        --suffix LD_LIBRARY_PATH : ${lib.getLib gcc-unwrapped}/lib \
        --add-flags "--model $out/model"
      '';
    };

in
stdenv.mkDerivation
{
  inherit pname version;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${files}/launch $out/bin/mp4grep
  '';
}
