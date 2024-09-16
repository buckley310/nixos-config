{ symlinkJoin
, runCommand

, black
, cargo
, efm-langserver
, errcheck
, go
, gopls
, lua-language-server
, nil
, nodePackages
, pyright
, rust-analyzer
, rustc
, rustfmt
, vscode-langservers-extracted
, yaml-language-server
}:

let
  symlinkBin = path: runCommand "symlinkBin" { } ''
    mkdir -p $out/bin
    ln -s "${path}" $out/bin/
  '';

in
symlinkJoin {
  name = "bck-nvim-tools";
  paths = [
    black
    cargo
    efm-langserver
    errcheck
    go
    gopls
    lua-language-server
    nil
    pyright
    rust-analyzer
    rustc
    rustfmt
    vscode-langservers-extracted
    yaml-language-server

    (symlinkBin "${nodePackages.prettier}/bin/prettier")
    (symlinkBin "${nodePackages.typescript-language-server}/bin/typescript-language-server")
  ];
}
