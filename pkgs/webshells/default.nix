{ fetchgit, runCommand }:
let
  src = fetchgit {
    "url" = "https://gitlab.com/kalilinux/packages/webshells.git";
    "rev" = "kali/1.1+kali7";
    "sha256" = "00hra95dg0f5a0bvdmb1dms15yzbxm39wrw768jd8s4maq6s9pmj";
  };
in
runCommand "webshells" { } ''
  mkdir -p $out/share
  ln -s ${src} $out/share/webshells
''
