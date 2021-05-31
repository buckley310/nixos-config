{ stdenv, fetchFromGitHub, makeWrapper, gdb }:
let
  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = "2021.04";
    sha256 = "sha256-nxwVaUFtFlDFWCUpXPh4FOuqMJ+COsOZv9IyKZ6dvg8=";
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
