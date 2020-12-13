{ stdenv, python3, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "weevely";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "epinna";
    repo = "weevely3";
    rev = "v${version}";
    sha256 = "0sgjf7ihgipb33k73d84dcx7snv2fvbzyd0f4468k1w5w6zqm9xj";
  };

  pythonWithPkgs = python3.withPackages (ps: with ps; [
    Mako
    prettytable
    pyopenssl
    pysocks
    python-dateutil
    pyyaml
  ]);

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    ln -s ${src}/weevely.1 $out/share/man/man1/
    makeWrapper ${pythonWithPkgs}/bin/python $out/bin/weevely \
        --add-flags ${src}/weevely.py
  '';
}
