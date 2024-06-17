{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.swapspace;
in
{
  options.sconfig.swapspace = {
    enable = lib.mkEnableOption "swapspace";
    swapPath = lib.mkOption { type = lib.types.path; };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.swapPath} 0700 root root" ];
    systemd.services.swapspace = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStart = "${pkgs.swapspace}/bin/swapspace --swappath='${cfg.swapPath}'";
      };
    };
  };
}
