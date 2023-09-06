{ config, lib, pkgs, ... }:
let
  lower_left_triangle = builtins.fromJSON '' "\uE0B8" '';
  upper_left_triangle = builtins.fromJSON '' "\uE0BC" '';

in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    configure = {
      packages.sconfig.start = with pkgs.vimPlugins; [
        vim-gitgutter
        vim-nix
      ];
      customRC = ''
        set mouse=
        set encoding=utf-8
        scriptencoding utf-8
        set list nowrap scrolloff=9 updatetime=300 number
        highlight GitGutterAdd    ctermfg=10
        highlight GitGutterChange ctermfg=11
        highlight GitGutterDelete ctermfg=9
        let g:gitgutter_sign_removed = '${lower_left_triangle}'
        let g:gitgutter_sign_removed_first_line = '${upper_left_triangle}'
        let g:gitgutter_sign_modified_removed = '~~'
      '';
    };
  };
}
