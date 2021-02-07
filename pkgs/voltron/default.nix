{ stdenv
, callPackage
, fetchFromGitHub
, gdb
, makeWrapper
, python3
}:
let
  python = python3;

  voltron = python.pkgs.buildPythonPackage rec {
    pname = "voltron";
    version = "d9fef0bb4073d434c54415d55a1b5da92cb84696";

    src = fetchFromGitHub {
      owner = "snare";
      repo = pname;
      rev = version;
      sha256 = "0cc4q9fn1lgqfdxy8l2800izqqwlbs9zw4yab2dk9i5b686xyc6i";
    };

    propagatedBuildInputs = with python.pkgs; [
      blessed
      flask-restful
      pygments
      pysigset
      requests-unixsocket
      (callPackage ./scruffington.nix { python = python; })
    ];

    doCheck = false;
  };

in
stdenv.mkDerivation {
  name = "voltron-commands";
  phases = [ "installPhase" ];
  buildInputs = [ makeWrapper python ];
  installPhase = ''
    mkdir -p "$out/bin"
    ln -s ${voltron}/bin/voltron "$out/bin/vol"
    makeWrapper "${gdb}/bin/gdb" "$out/bin/voldb" \
        --add-flags "-x $(toPythonPath ${voltron})/voltron/entry.py" \
        --suffix PYTHONPATH : "${python.pkgs.makePythonPath [ voltron ]}"
  '';
}
