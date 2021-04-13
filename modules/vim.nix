{ config, pkgs, ... }:
let
  legacy = (config.system.nixos.release == "20.09");
in
{

  environment.systemPackages = if legacy then [ pkgs.vim ] else [ ];

  programs = if legacy then { } else {
    neovim = {
      enable = true;
      viAlias = true;
      configure = {
        packages.foo.start = [ pkgs.vimPlugins.vim-nix ];
        customRC = ''
          set nowrap scrolloff=9
        '';
      };
    };
  };

}
