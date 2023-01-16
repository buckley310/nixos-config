{ fetchFromGitHub, runCommand }:
let

  src = fetchFromGitHub {
    owner = "danielmiessler";
    repo = "SecLists";
    rev = "2022.4";
    sha256 = "CCj662K1+CstJmFKeB+vbPomkxyErzY3mJcOrWs9cf4=";
  };

in
runCommand "seclists" { } ''
  mkdir -p $out/share
  ln -s ${src} $out/share/seclists
''
