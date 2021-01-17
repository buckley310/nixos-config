{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.flakes;
in
{
  options.sconfig.flakes = lib.mkEnableOption "Enable Flakes";

  config = lib.mkIf cfg {
    environment.systemPackages = [ pkgs.nixFlakes ];
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}
