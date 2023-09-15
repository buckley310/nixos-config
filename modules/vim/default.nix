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
        nerdtree
        vim-autoformat
        vim-gitgutter
        vim-nix
        vim-startify
      ];
      customRC = ''
        source ${./init.vim}
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
