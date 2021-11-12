{ stdenv, lib, fetchFromGitHub, makeWrapper, gdb, python3 }:
let

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = "2021.10";
    sha256 = "7kIR9lzKBb1rArb9l1Tu10RJ9uacifvy2EbkmrMFK2Y=";
  };

  reqs = lib.splitString "\n" (lib.fileContents (./. + "/requirements.txt"));

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
        --add-flags "-x ${src}/gef.py"
  '';
  meta.platforms = [ "x86_64-linux" ];
}
