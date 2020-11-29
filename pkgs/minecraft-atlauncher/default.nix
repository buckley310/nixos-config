{ fetchurl, writeShellScript, jre8, buildFHSUserEnv }:
let
  name = "minecraft-atlauncher";
  version = "3.4.0.2";

  atJar = fetchurl {
    url = "https://github.com/ATLauncher/ATLauncher/releases/download/${version}/ATLauncher-${version}.jar";
    sha256 = "5bf55ba0134e2bfbd99cf1b720cf24eb296bf2875af117fd6a845f5a408a60f4";
  };

in
buildFHSUserEnv {
  inherit name;
  targetPkgs = pkgs: [ pkgs.alsaLib ];
  runScript = writeShellScript name ''
    set -ex
    installPath=~/.atlauncher
    mkdir -p "$installPath"
    cd "$installPath"
    exec ${jre8}/bin/java -jar "${atJar}" --working-dir "$installPath"
  '';
}
