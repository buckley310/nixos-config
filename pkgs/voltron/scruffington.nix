{ fetchFromGitHub, python }:

python.pkgs.buildPythonPackage rec {
  pname = "scruffington";
  version = "0.3.8.2";

  propagatedBuildInputs = with python.pkgs; [ six pyyaml nose ];

  src = fetchFromGitHub {
    owner = "snare";
    repo = "scruffy";
    rev = "v${version}";
    sha256 = "1v5zq0m0pm0pccsa8qgdi0z74vh8m1ylshxvgmj3ml87p4vd3haw";
  };
}
