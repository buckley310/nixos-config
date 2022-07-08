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
      ];

      boot.extraModulePackages =
        lib.optional
          (lib.versionOlder config.boot.kernelPackages.kernel.version "5.16")
          (config.boot.kernelPackages.hid-nintendo);

    };
}
