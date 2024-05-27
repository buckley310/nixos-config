{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.plasma;
in
{
  options.sconfig.plasma = lib.mkEnableOption "Enable Plasma Desktop";

  config = lib.mkIf cfg {
    services.libinput.enable = true;
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
    hardware.pulseaudio.enable = true;
    environment.systemPackages = [ pkgs.arc-theme ]; # fix hand cursor in firefox
  };
}
