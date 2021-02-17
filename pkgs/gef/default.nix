{ stdenv, fetchFromGitHub, makeWrapper, gdb }:
let
  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = "2021.01";
    sha256 = "0gw112s16pdjd5csp8ap0qq2d3bkp2s8pyhjbw4f8k0mkgy1j66i";
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
