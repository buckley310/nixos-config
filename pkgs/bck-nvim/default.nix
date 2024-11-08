{
  lib,
  extraBinPaths ? [ ],
  neovim-unwrapped,
  vimPlugins,
  wrapNeovim,
}:

let
  luafiles = lib.concatLines (
    map (x: "luafile ${./lua}/${x}") (builtins.attrNames (builtins.readDir ./lua))
  );

  extraPath = lib.concatLines (map (p: "let $PATH .= ':${p}/bin'") (extraBinPaths));

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
