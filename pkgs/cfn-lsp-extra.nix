{ fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "cfn-lsp-extra";
  version = "0.7.2";
  pyproject = true;

  src = fetchFromGitHub {
    repo = pname;
    rev = "v${version}";
    owner = "laurencewarne";
    hash = "sha256-tRbK1oHH6LI/y8Ku8nvAVDFiCy+YrKwEqrBHgTNj788=";
  };

  dependencies = with python3Packages; [
    pyyaml
    attrs
    aws-sam-translator
    botocore
    cfn-lint
    click
    importlib-resources
    platformdirs
    pygls
    types-pyyaml
  ];

  build-system = with python3Packages; [
    poetry-core
    poetry-dynamic-versioning
  ];
}
