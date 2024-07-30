{ symlinkJoin
, black
, efm-langserver
, lua-language-server
, nil
, nodePackages
, pyright
, vscode-langservers-extracted
, yaml-language-server
}:

symlinkJoin {
  name = "bck-nvim-tools";
  paths = [
    black
    efm-langserver
    lua-language-server
    nil
    nodePackages.prettier
    nodePackages.typescript-language-server
    pyright
    vscode-langservers-extracted
    yaml-language-server
  ];
}
