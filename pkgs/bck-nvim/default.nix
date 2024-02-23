{ lib
, neovim-unwrapped
, vimPlugins
, wrapNeovim

  # LSP
, black
, efm-langserver
, lua-language-server
, nil
, nodePackages
, pyright
, vscode-langservers-extracted
, yaml-language-server
}:

let
  luafiles = lib.concatLines (map
    (x: "luafile ${./lua}/${x}")
    (builtins.attrNames (builtins.readDir ./lua))
  );

  extraPath = lib.concatLines (map
    (p: "let $PATH .= ':${p}/bin'")
    [
      black
      efm-langserver
      lua-language-server
      nil
      nodePackages.prettier
      nodePackages.typescript-language-server
      pyright
      vscode-langservers-extracted
      yaml-language-server
    ]
  );

in
wrapNeovim neovim-unwrapped {
  viAlias = true;
  vimAlias = true;
  configure = {
    packages.bck.start = with vimPlugins; [
      # cmp
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      luasnip
      nvim-cmp
      # other
      bufferline-nvim
      comment-nvim
      gitsigns-nvim
      indent-blankline-nvim
      lualine-nvim
      nvim-lspconfig
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      project-nvim
      telescope-nvim
      vim-code-dark
      vim-tmux-navigator
    ];
    customRC = extraPath + luafiles;
  };
}
