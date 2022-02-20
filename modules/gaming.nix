{ config, lib, pkgs, ... }:

let
  cfg = config.sconfig.gaming;
in
{
  options.sconfig.gaming.enable = lib.mkEnableOption "Enable Gaming";

  config = lib.mkIf cfg.enable
    {
      programs.steam.enable = true;
      environment.systemPackages = with pkgs; [
        obs-studio
        steam-run
      ];
    };
}
