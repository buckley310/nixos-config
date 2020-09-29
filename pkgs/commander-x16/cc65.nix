{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "cc65";

  src = fetchFromGitHub {
    owner = name;
    repo = name;
    rev = "b525554bfee3c3ddc5ddd7e58b4a20728f6c9cb1";
    sha256 = "0san7n092bx823pliypvvsbhhzq9q39n1qqivjcyc2xab2dwir84";
  };

  buildPhase = ''
    make PREFIX="$out"
  '';

  installPhase = ''
    make install PREFIX="$out"
  '';
}
