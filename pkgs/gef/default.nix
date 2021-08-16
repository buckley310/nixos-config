{ stdenv, lib, fetchFromGitHub, makeWrapper, gdb, python3 }:
let

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = "2021.07";
    sha256 = "zKn3yS9h8bzjsb/iPgNU8g5IgXFBaKvM7osTqzzv16s=";
  };

  reqs =
    (builtins.filter (x: x != "")
      (lib.splitString "\n"
        (builtins.readFile "${src}/requirements.txt")));

  # python3.pkgs.ropper does not work with makePythonPath. Swap it out.
  pyp = python3.pkgs // {
    ropper = python3.pkgs.buildPythonPackage {
      inherit (python3.pkgs.ropper) name src propagatedBuildInputs;
    };
  };

  optionals = pyp.makePythonPath (map (x: pyp.${x}) reqs);

in
stdenv.mkDerivation {
  name = "gef";
  phases = [ "installPhase" ];
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper "${gdb}/bin/gdb" "$out/bin/gef" \
        --suffix PYTHONPATH : "${optionals}" \
        --add-flags "-x ${src}/gef.py" \
        --add-flags "-ex 'gef config context.clear_screen 0'"
  '';
}
