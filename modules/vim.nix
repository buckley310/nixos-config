{ pkgs, ... }:
let
  alias = cmd: pkgs.writeShellScriptBin cmd ''
    exec nix run github:buckley310/vim -- "$@"
  '';
in
{
  environment.systemPackages = [
    (alias "vi")
    (alias "vim")
  ];
}
