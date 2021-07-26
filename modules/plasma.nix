{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.plasma;
in
{
  options.sconfig.plasma = lib.mkEnableOption "Enable Plasma Desktop";

  config = lib.mkIf cfg {
    services.xserver = {
      enable = true;
      libinput.enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
    hardware.pulseaudio.enable = true;
  };
}
