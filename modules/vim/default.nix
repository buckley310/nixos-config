{ config, lib, pkgs, ... }:
{
  environment.variables.EDITOR = "vim";

  environment.systemPackages = with pkgs; [
    lunarvim
    nodePackages.prettier

    (writeShellScriptBin "black" ''
      exec ${pkgs.python3.pkgs.black}/bin/black "$@"
    '')
  ];
}
