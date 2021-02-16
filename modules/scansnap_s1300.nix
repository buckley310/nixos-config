{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.scansnap-s1300;
in
{
  options.sconfig.scansnap-s1300 = lib.mkEnableOption "Enable S1300 Scanning";

  config = lib.mkIf cfg {
    hardware.sane.enable = true;
    nixpkgs.config.sane.extraFirmware = [{
      name = "1300_0C26.nal";
      backend = "epjitsu";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/stevleibelt/scansnap-firmware/96c3a8b2a4e4f1ccc4e5827c5eb5598084fd17c8/1300_0C26.nal";
        sha256 = "d693c9150fb00442d3f33f103ffb028410cd3cc53cf3d6df0817fb9d596b17f3";
      };
    }];
  };
}
