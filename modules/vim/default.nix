{ config, lib, pkgs, ... }:
{
  environment.variables.EDITOR = "vim";

  environment.etc."lvim.lua".source = ./init.lua;

  environment.etc."my-settings.sh".text = ''
    mkdir -p ~/.config/lvim
    echo 'vim.cmd("luafile /etc/lvim.lua")' >~/.config/lvim/config.lua
  '';

  environment.systemPackages = with pkgs; [
    lunarvim
    nodePackages.prettier

    (writeShellScriptBin "black" ''
      exec ${pkgs.python3.pkgs.black}/bin/black "$@"
    '')

    (writeShellScriptBin "vi" ''
      exec lvim "$@"
    '')

    (writeShellScriptBin "vim" ''
      exec lvim "$@"
    '')
  ];
}
