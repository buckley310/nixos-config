{ nixos-rebuild
, python3
, writeShellScriptBin
}:

writeShellScriptBin "deploy" ''
  export PATH="$PATH:${nixos-rebuild}/bin"
  exec ${python3}/bin/python ${./deploy.py} "$@"
''
