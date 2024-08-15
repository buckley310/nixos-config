{ runCommand }: {

  b64decode = input:
    builtins.readFile
      (runCommand "b64decode" { } ''
        base64 -d >$out <${builtins.toFile "input" input}
      '');

  b64encode = input:
    builtins.readFile
      (runCommand "b64encode" { } ''
        base64 -w0 >$out <${builtins.toFile "input" input}
      '');

}
