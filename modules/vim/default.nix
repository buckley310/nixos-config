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
        nerdtree-git-plugin
        vim-autoformat
        vim-code-dark
        vim-devicons
        vim-gitgutter
        vim-nix
        vim-startify
      ] ++
      # skip syntax-highlight on nixos 23.05
      lib.optional
        (vim-nerdtree-syntax-highlight.version != "2021-01-11")
        (vim-nerdtree-syntax-highlight);

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
