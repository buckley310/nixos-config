{ stdenv, fetchFromGitHub, glib, nodePackages }:

stdenv.mkDerivation rec {
  pname = "pop-shell";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = version;
    sha256 = "0nws28w40xpwhgdpcifzys1md4h6a7q5k3wcn2a77z5m26g69zw2";
  };

  preInstall = ''
    mkdir $out
    ln -s $out ./usr
    export DESTDIR="$(pwd)"
  '';

  buildInputs = [ glib nodePackages.typescript ];
}
