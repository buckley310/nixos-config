{ config, lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    configure = {
      packages.sconfig.start = with pkgs.vimPlugins; [
        airline
        bufferline-nvim
        coc-nvim
        coc-tsserver
        nerdtree
        vim-autoformat
        vim-code-dark
        vim-gitgutter
        vim-nix
        vim-startify
      ];
      customRC = ''
        source ${./init.vim}
        luafile ${./init.lua}
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    nodePackages.prettier
    (writeShellScriptBin "black" ''
      exec ${pkgs.python3.pkgs.black}/bin/black "$@"
    '')
  ];
}