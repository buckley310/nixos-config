# https://feed-the-beast.com/

{ fetchurl
, steam-run
, writeShellScriptBin
}:

let
  installer = fetchurl {
    url = "https://apps.modpacks.ch/FTBApp/release/202401041638-9dc7936164/FTBA_unix_202401041638-9dc7936164.sh";
    sha256 = "7806cbf6dd0f91a83ea81f1f3450b586d93a479c9e2982751b2124b9c3e25481";
  };

in
writeShellScriptBin "ftb" ''
  [ -d ~/FTBA ] || ${steam-run}/bin/steam-run bash ${installer} -q
  ${steam-run}/bin/steam-run ~/FTBA/FTBApp
''
