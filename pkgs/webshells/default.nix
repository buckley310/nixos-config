{ fetchgit, runCommand }:
let
  src = fetchgit {
    "url" = "https://gitlab.com/kalilinux/packages/webshells.git";
    "rev" = "603ab1f6b8f2f12abc5753183941e599153099eb";
    "sha256" = "sha256-2P0iC4XVgQu40mRhMn3ibfWIQ7dCd8sLoHPPNMfy3H8=";
  };
in
runCommand "webshells" { } ''
  mkdir -p $out/share
  ln -s ${src} $out/share/webshells
''
