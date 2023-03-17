{ writeShellScriptBin, python3 }:

writeShellScriptBin "deploy" ''
  exec ${python3}/bin/python ${./deploy.py} "$@"
''
