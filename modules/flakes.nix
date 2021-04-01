{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.flakes;
in
{
  options.sconfig.flakes = lib.mkEnableOption "Enable Flakes";

  config = lib.mkIf cfg {
    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
