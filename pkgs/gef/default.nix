{ stdenv, fetchFromGitHub, makeWrapper, gdb }:
let
  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = "2021.07";
    sha256 = "zKn3yS9h8bzjsb/iPgNU8g5IgXFBaKvM7osTqzzv16s=";
  };

in
stdenv.mkDerivation {
  name = "gef";
  phases = [ "installPhase" ];
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper "${gdb}/bin/gdb" "$out/bin/gef" \
        --add-flags "-x ${src}/gef.py" \
        --add-flags "-ex 'gef config context.clear_screen 0'"
  '';
}
